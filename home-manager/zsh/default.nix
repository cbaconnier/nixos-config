{ pkgs, ... }:

{
 programs.zsh = {
  enable = true;
   oh-my-zsh = {
    enable = true;
    theme = "refined";
    plugins = [ 
     "git" 
     "docker"
     "colored-man-pages" 
     #"zsh-syntax-highlighting"
     "emoji"
     "emotty" 
    ]; 
   };
 };
}
