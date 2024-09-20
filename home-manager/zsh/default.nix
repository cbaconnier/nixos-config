{ pkgs, ... }:

{
 programs.zsh = {
   enable = true;
   syntaxHighlighting.enable = true;
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
 };
}
