{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
      sail-bootstrap = ''
        docker run --rm \
          -u "$(id -u):$(id -g)" \
          -v "$(pwd):/var/www/html" \
          -w /var/www/html \
          laravelsail/php83-composer:latest \
          composer install --ignore-platform-reqs
      '';
    };

    initContent = ''
      vapor () {
        local VAPOR_PATH=~/.config/composer/vendor/bin/vapor
        if [[ "$*" == *"production"* ]]; then
            echo -n "Enter \"''${PWD##*/}\" to confirm: "
            read answer
            if [ "$answer" = ''${PWD##*/} ]; then
                $VAPOR_PATH "$@"
            else
               echo "Failed"
            fi
        else
            $VAPOR_PATH "$@"
        fi
      }
    '';

    oh-my-zsh = {
      enable = true;
      theme = "refined";
      plugins = [ "git" "docker" "colored-man-pages" "emoji" "emotty" ];
    };

    zplug = {
      enable = true;
      plugins = [{ name = "jessarcher/zsh-artisan"; }];
    };

  };
}
