
{ pkgs, ... }:

{

 programs.git = {
  enable = true;
  userName = "Clément Baconnier";
  userEmail = "clement@baconnier.ch";  
  aliases = {
    lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
	  lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
    recent-branches = "!git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)' | nl -w2 -s'> ' ";
  };
  extraConfig = {
    init.defaultBranch = "main";
    color = {
     diff = "auto";
     status = "auto";
     branch = "auto";
    };
    push.autoSetupRemote = true;
  };
 };

}
