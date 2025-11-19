{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Clément Baconnier";
        email = "clement@baconnier.ch";
      };
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
      push = { autoSetupRemote = true; };
      pull = { rebase = true; };
      alias = {
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        recent-branches =
          "!git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)' | nl -w2 -s'> ' ";
      };
    };
  };
}
