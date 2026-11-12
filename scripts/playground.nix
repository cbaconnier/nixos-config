{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "playground";
  runtimeInputs = [
    pkgs.openssh
    pkgs.gnutar
    pkgs.gnused
    pkgs.gnugrep
    pkgs.rsync
    pkgs.socat
    pkgs.coreutils
    pkgs.systemd
  ];
  text = ''
    usage() {
      echo "usage: playground status | sync | run [--no-sync] COMMAND... | get [--open] PATH" >&2
      echo "       playground clean [--files [--all]] [--docker]" >&2
      echo "       playground start | stop | restart | reset | logs | load IMAGE..." >&2
      echo "       playground net on | off | status" >&2
      exit 2
    }

    case "''${1:-}" in
      start | stop | restart | reset | logs | net)
        if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
          echo "playground: $1 must be run from your own terminal, outside claude" >&2
          exit 1
        fi
        net_state="$XDG_RUNTIME_DIR/playground-net"
        net_monitor() {
          local sock="$XDG_RUNTIME_DIR/playground-monitor.sock"
          if [[ ! -S "$sock" ]]; then
            echo "playground: the VM is not running (no control socket)" >&2
            exit 1
          fi
          local out
          out=$({ printf '%s\n' "$1"; sleep 0.3; } | socat - "UNIX-CONNECT:$sock")
          if grep -qiE 'not found|error' <<<"$out"; then
            echo "playground: QEMU refused the command: $(tr -d '\r' <<<"$out" | grep -iE 'not found|error' | head -1)" >&2
            exit 1
          fi
        }
        if [[ "$1" == net ]]; then
          case "''${2:-status}" in
            on)
              net_monitor "set_link virtio-net-pci.0 on"
              echo on > "$net_state"
              echo "playground: network on"
              ;;
            off)
              net_monitor "set_link virtio-net-pci.0 off"
              echo off > "$net_state"
              echo "playground: network off (the VM cannot reach the internet or your network; run, sync and get still work)"
              ;;
            status)
              if [[ "$(cat "$net_state" 2>/dev/null)" == on ]]; then
                echo "playground: network on"
              else
                echo "playground: network off"
              fi
              ;;
            *)
              usage
              ;;
          esac
          exit 0
        fi
        if [[ "$1" == logs ]]; then
          exec journalctl -u playground-vm "''${@:2}"
        fi
        if [[ "$1" == reset ]]; then
          systemctl stop playground-vm
          rm -f "''${XDG_STATE_HOME:-$HOME/.local/state}/playground/disk.qcow2"
          exec systemctl start playground-vm
        fi
        exec systemctl "$1" playground-vm
        ;;
    esac

    key="$HOME/.ssh/id_ed25519_claude"
    if [[ ! -r "$key" ]]; then
      echo "playground: $key is not readable" >&2
      exit 1
    fi

    workdir=$(pwd -P)
    owner=$(basename "$(dirname "$workdir")")
    name=$(basename "$workdir")
    for part in "$owner" "$name"; do
      if [[ ! "$part" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo "playground: unsupported directory name: $part" >&2
        exit 1
      fi
    done
    remote_dir="\$HOME/work/$owner/$name"

    ssh_opts=(-i "$key" -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=15
      -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -p 2222)

    remote() {
      # shellcheck disable=SC2029
      ssh "''${ssh_opts[@]}" runner@127.0.0.1 "$@"
    }

    sync_workdir() {
      rsync -a --delete --chown=runner:users \
        --include='.env.example' --exclude='.git' --exclude='.env' --exclude='.env.*' \
        --rsync-path="mkdir -p work/$owner/$name && /run/wrappers/bin/sudo -n rsync" \
        -e "ssh ''${ssh_opts[*]}" \
        "$workdir"/ "runner@127.0.0.1:work/$owner/$name/"
    }

    case "''${1:-}" in
      status)
        remote 'echo playground ok'
        ;;
      sync)
        if ! sync_workdir; then
          echo "playground: sync FAILED for $owner/$name, the copy in the VM is incomplete (see the error above; check that the VM is running and its disk is not full)" >&2
          exit 1
        fi
        echo "playground: synced $owner/$name"
        ;;
      run)
        shift
        nosync=0
        if [[ "''${1:-}" == --no-sync ]]; then
          nosync=1
          shift
        fi
        [[ $# -gt 0 ]] || usage
        if [[ $nosync -eq 0 ]] && ! sync_workdir; then
          echo "playground: sync FAILED for $owner/$name, not running the command (see the error above; check that the VM is running and its disk is not full)" >&2
          exit 1
        fi
        remote "cd $remote_dir && $*"
        ;;
      get)
        shift
        open=0
        if [[ "''${1:-}" == --open ]]; then
          open=1
          shift
          if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
            echo "playground: get --open must be run from your own terminal, outside claude" >&2
            exit 1
          fi
        fi
        [[ $# -eq 1 ]] || usage
        src="$1"
        if [[ ! "$src" =~ ^[A-Za-z0-9._/+@\ -]+$ || "$src" == *..* ]]; then
          echo "playground: unsupported path: $src (allowed: letters, digits, spaces and . _ / + @ -)" >&2
          exit 1
        fi
        if ! resolved=$(remote "cd $remote_dir && realpath -e -- $(printf '%q' "$src") 2>/dev/null"); then
          echo "playground: not found in the VM: $src" >&2
          exit 1
        fi
        workdir_root="/home/runner/work/$owner/$name"
        if [[ ! "$resolved" =~ ^[A-Za-z0-9._/+@\ -]+$ || ( "$resolved" != "$workdir_root" && "$resolved" != "$workdir_root"/* ) ]]; then
          echo "playground: $src is outside this work directory's copy in the VM" >&2
          exit 1
        fi
        uid=$(id -u)
        workdir_key=$(printf '%s' "$workdir" | sed 's/[^A-Za-z0-9]/-/g')
        if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
          out_base="/tmp/claude-$uid/$workdir_key"
        else
          scratch_root="/tmp/claude-scratchpad-$uid"
          mkdir -m 700 "$scratch_root" 2>/dev/null || true
          if [[ -L "$scratch_root" || ! -O "$scratch_root" ]]; then
            echo "playground: $scratch_root is not a directory of yours, refusing to use it" >&2
            exit 1
          fi
          chmod 700 "$scratch_root"
          out_base="$scratch_root/$workdir_key"
        fi
        q_resolved=$(printf '%q' "$resolved")
        mkdir -p "$out_base/outputs"
        base=$(basename "$resolved")
        target="$out_base/outputs/$base"
        partial="$target.partial"
        rm -rf "$partial"
        if remote "test -d $q_resolved"; then
          mkdir -p "$partial"
          if ! remote "tar -C $q_resolved -cf - ." | tar --warning=no-timestamp -C "$partial" -xf -; then
            rm -rf "$partial"
            echo "playground: could not copy the directory: $base" >&2
            exit 1
          fi
        else
          if ! remote "cat -- $q_resolved" > "$partial"; then
            rm -f "$partial"
            echo "playground: could not copy the file: $base" >&2
            exit 1
          fi
          if [[ ! -s "$partial" ]]; then
            rm -f "$partial"
            echo "playground: the file is empty: $base" >&2
            exit 1
          fi
        fi
        rm -rf "$target"
        mv "$partial" "$target"
        echo "playground: saved /tmp/claude-scratchpad-$uid/$workdir_key/outputs/$base"
        if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
          echo "playground: readable from this sandbox at $target"
          echo "playground: to open it on your screen, run in your own terminal, from the work directory: playground get --open $(printf '%q' "$src")"
        fi
        if [[ $open -eq 1 ]]; then
          ext="''${base##*.}"
          ext="''${ext,,}"
          if [[ -d "$target" ]]; then
            echo "playground: not opened: $base is a directory"
          else
            case "$ext" in
              png | jpg | jpeg | gif | webp | txt | log | pdf)
                if ! command -v xdg-open >/dev/null; then
                  echo "playground: not opened: xdg-open is not available"
                else
                  xdg-open "$target" >/dev/null 2>&1 &
                fi
                ;;
              *)
                echo "playground: not opened: .$ext is not in the list of safe extensions (png, jpg, jpeg, gif, webp, txt, log, pdf)"
                ;;
            esac
          fi
        fi
        ;;
      load)
        if [[ -z "''${XDG_RUNTIME_DIR:-}" ]]; then
          echo "playground: load must be run from your own terminal, outside claude" >&2
          exit 1
        fi
        shift
        [[ $# -gt 0 ]] || usage
        docker save "$@" | remote 'docker load'
        ;;
      clean)
        shift
        [[ $# -gt 0 ]] || usage
        files=0
        all=0
        docker=0
        for arg in "$@"; do
          case "$arg" in
            --files) files=1 ;;
            --all) all=1 ;;
            --docker) docker=1 ;;
            *) usage ;;
          esac
        done
        [[ $all -eq 0 || $files -eq 1 ]] || usage
        if [[ $docker -eq 1 ]]; then
          remote 'docker system prune -af --volumes'
        fi
        if [[ $files -eq 1 && $all -eq 1 ]]; then
          remote "sudo -n rm -rf \$HOME/work && mkdir -p \$HOME/work"
        elif [[ $files -eq 1 ]]; then
          remote "sudo -n rm -rf $remote_dir; rmdir \$HOME/work/$owner 2>/dev/null || true"
        fi
        ;;
      *)
        usage
        ;;
    esac
  '';
}
