{ pkgs }:

pkgs.writeShellScript "askpass-stars" ''
  printf '%s' "$1" >/dev/tty

  case "$1" in
    *[Pp]assphrase* | *[Pp]assword*) ;;
    *)
      IFS= read -r answer </dev/tty
      printf '%s\n' "$answer"
      exit
      ;;
  esac

  pw=""
  while IFS= read -rsn1 c </dev/tty; do
    [ -n "$c" ] || break
    if [ "$c" = $'\177' ] || [ "$c" = $'\b' ]; then
      if [ -n "$pw" ]; then
        pw=''${pw%?}
        printf '\b \b' >/dev/tty
      fi
      continue
    fi
    pw+=$c
    printf '*' >/dev/tty
  done

  printf '\n' >/dev/tty
  printf '%s\n' "$pw"
''
