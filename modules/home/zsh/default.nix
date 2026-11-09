{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    shellAliases = {
      ssh = "kitten ssh";
      sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
      sail-bootstrap = ''
        docker run --rm \
          -v "$(pwd):/app" \
          -w /app \
          composer:latest \
          composer install --ignore-platform-reqs --no-scripts
      '';
    };

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