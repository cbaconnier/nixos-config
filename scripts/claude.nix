{ pkgs, ... }:

let
  box = pkgs.writeShellApplication {
    name = "claude";
    runtimeInputs = [
      pkgs.bubblewrap
      pkgs.coreutils
      pkgs.gnused
    ];
    text = ''
      usage() {
        echo "usage: claude [--rw PATH] [--ro PATH] [--nix] [claude args...]" >&2
        exit 2
      }

      rw=()
      ro=()
      nix=0
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --rw) [[ $# -ge 2 ]] || usage; rw+=("$2"); shift 2 ;;
          --ro) [[ $# -ge 2 ]] || usage; ro+=("$2"); shift 2 ;;
          --nix) nix=1; shift ;;
          --) shift; break ;;
          *) break ;;
        esac
      done

      workdir=$(pwd -P)
      if [[ "$HOME/" == "$workdir"/* ]]; then
        echo "claude: refusing to expose $workdir, cd into a work directory first (claude-unsafe to bypass)" >&2
        exit 1
      fi

      claude_dir="$HOME/.claude"
      uid=$(id -u)
      workdir_key=$(printf '%s' "$workdir" | sed 's/[^A-Za-z0-9]/-/g')
      scratch_root="/tmp/claude-scratchpad-$uid"
      scratch_dir="$scratch_root/$workdir_key"
      mkdir -m 700 "$scratch_root" 2>/dev/null || true
      if [[ -L "$scratch_root" || ! -O "$scratch_root" ]]; then
        echo "claude: $scratch_root is not a directory of yours, refusing to use it" >&2
        exit 1
      fi
      chmod 700 "$scratch_root"
      mkdir -p "$scratch_dir"

      args=(
        --die-with-parent
        --unshare-pid --unshare-ipc --unshare-uts
        --proc /proc --dev /dev --tmpfs /tmp
        --ro-bind /nix/store /nix/store
        --ro-bind-try /run/current-system/sw /run/current-system/sw
        --ro-bind /etc/static /etc/static
        --ro-bind-try /etc/profiles /etc/profiles
        --ro-bind-try /etc/hosts /etc/hosts
        --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf
        --ro-bind-try /etc/resolv.conf /etc/resolv.conf
        --ro-bind-try /etc/passwd /etc/passwd
        --ro-bind-try /etc/group /etc/group
        --ro-bind-try /etc/ssl /etc/ssl
        --ro-bind-try /etc/localtime /etc/localtime
        --ro-bind-try /etc/zoneinfo /etc/zoneinfo
        --ro-bind-try /etc/terminfo /etc/terminfo
        --ro-bind-try /bin /bin
        --ro-bind-try /usr/bin /usr/bin
      )

      args+=(
        --bind "$workdir" "$workdir"
        --bind "$claude_dir" "$claude_dir"
        --bind "$scratch_dir" "/tmp/claude-$uid/$workdir_key"
        --bind-try "$HOME/.claude.json" "$HOME/.claude.json"
        --ro-bind-try "$claude_dir/settings.local.json" "$claude_dir/settings.local.json"
        --ro-bind-try "$HOME/.gitconfig" "$HOME/.gitconfig"
        --ro-bind-try "$HOME/.config/git" "$HOME/.config/git"
        --ro-bind-try "$HOME/.ssh/id_ed25519_claude" "$HOME/.ssh/id_ed25519_claude"
      )

      if [[ $nix -eq 1 ]]; then
        args+=(
          --ro-bind /etc/nix /etc/nix
          --bind /nix/var/nix/daemon-socket /nix/var/nix/daemon-socket
          --setenv NIX_REMOTE daemon
        )
      fi

      for p in "''${rw[@]}"; do args+=(--bind "$p" "$p"); done
      for p in "''${ro[@]}"; do args+=(--ro-bind "$p" "$p"); done

      args+=(
        --clearenv
        --setenv HOME "$HOME"
        --setenv USER "$USER"
        --setenv LOGNAME "$USER"
        --setenv PATH "/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin"
        --setenv TERM "''${TERM:-xterm-256color}"
        --setenv COLORTERM "''${COLORTERM:-truecolor}"
        --setenv LANG "''${LANG:-C.UTF-8}"
        --setenv SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
        --chdir "$workdir"
      )

      [[ -z "''${TERMINFO:-}" ]] || args+=(--setenv TERMINFO "$TERMINFO")
      [[ -z "''${TERMINFO_DIRS:-}" ]] || args+=(--setenv TERMINFO_DIRS "$TERMINFO_DIRS")

      exec bwrap "''${args[@]}" ${pkgs.claude-code}/bin/claude "$@"
    '';
  };

  unsafe = pkgs.writeShellScriptBin "claude-unsafe" ''
    exec ${pkgs.claude-code}/bin/claude "$@"
  '';
in
pkgs.symlinkJoin {
  name = "claude";
  paths = [
    box
    unsafe
  ];
}
