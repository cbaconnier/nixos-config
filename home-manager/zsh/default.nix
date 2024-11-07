{ pkgs, ... }:

{
 programs.zsh = {
   enable = true;
   syntaxHighlighting.enable = true;
   shellAliases = {
      sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
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
     plugins = [
       { name = "jessarcher/zsh-artisan"; }
     ];
   };
 };
}
