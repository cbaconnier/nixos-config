{ pkgs, config, ... }:

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
      # alias ssh="kitten ssh" breaks tab completion, hence the function
      # issue : https://github.com/kovidgoyal/kitty/issues/7491
      ssh() { kitten ssh "$@"; }

      # ssh without kitten, because kitten breaks remote commands (ssh <host> 'command')
      sshc() { command ssh "$@"; }
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
