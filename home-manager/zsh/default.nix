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
        PHP_VERSION=$(jq -r '.require.php' composer.json | grep -oP '\d+\.\d+' | head -1 | tr -d '.')
        docker run --rm \
          -u "$(id -u):$(id -g)" \
          -v "$(pwd):/var/www/html" \
          -w /var/www/html \
          laravelsail/php''${PHP_VERSION}-composer:latest \
          composer install --ignore-platform-reqs
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
}
