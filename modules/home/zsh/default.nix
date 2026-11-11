{ pkgs, config, ... }:

let
  askpass = import ./askpass-stars.nix { inherit pkgs; };
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    shellAliases = {
      sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
      sail-bootstrap = ''
        docker run --rm \
          -v "$(pwd):/app" \
          -w /app \
          composer:latest \
          composer install --ignore-platform-reqs --no-scripts
      '';
    };

    initContent = ''
      # star prompt for the passphrase of commands that spawn ssh
      _ssh_show_stars() {
        local -x SSH_ASKPASS=${askpass} SSH_ASKPASS_REQUIRE=force
        command "$@"
      }

      # alias ssh="kitten ssh" breaks tab completion, hence the function
      # issue : https://github.com/kovidgoyal/kitty/issues/7491
      ssh() { _ssh_show_stars kitten ssh "$@"; }
      scp() { _ssh_show_stars scp "$@"; }
      sftp() { _ssh_show_stars sftp "$@"; }
      rsync() { _ssh_show_stars rsync "$@"; }
    '';

    oh-my-zsh = {
      enable = true;
      theme = "refined";
      plugins = [
        "git"
        "docker"
        "colored-man-pages"
        "emoji"
        "emotty"
      ];
    };

    zplug = {
      enable = true;
      plugins = [ { name = "jessarcher/zsh-artisan"; } ];
    };

  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
