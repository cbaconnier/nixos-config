{ config, pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    # Install the required packages that were previously in extraPackages
    extraPackages = with pkgs; [
      # NVChad Requirements
      gcc
      nodejs
      lua5_1
      lua-language-server
      ripgrep
      tree-sitter
      git
      
      # PHP/Laravel Development
      nodePackages.intelephense
      phpactor

      # Web Development
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      tailwindcss-language-server

      # Additional useful tools
      fd

      # Other LSP
      nixd
    ];
  };
 
  # Clone my nvim configuration with write access and create a backup when the directory has uncommitted changes.
# home.activation = {
#     cloneNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
#       nvimConfigPath="${config.home.homeDirectory}/.config/nvim"
#       backupDir="${config.home.homeDirectory}/.config/nvim_backups"
#       timestamp=$(date +%Y%m%d_%H%M%S)
#
#       # Check if nvim directory exists
#       if [ -d "$nvimConfigPath" ]; then
#         cd "$nvimConfigPath"
#
#         # Check for uncommitted changes (modified, untracked, or staged files)
#         if ! ${pkgs.git}/bin/git diff-index --quiet HEAD -- || \
#            [ -n "$(${pkgs.git}/bin/git ls-files --others --exclude-standard)" ]; then
#
#           # Run the backup
#           $DRY_RUN_CMD mkdir -p "$backupDir"
#           $DRY_RUN_CMD cp -r "$nvimConfigPath" "$backupDir/nvim_$timestamp"
#
#           # Keep only the 10 most recent backups
#           # $DRY_RUN_CMD cd "$backupDir" && ls -t | tail -n +11 | xargs -r rm -rf
#         fi
#
#         # Clean and reset the git directory
#         $DRY_RUN_CMD ${pkgs.git}/bin/git clean -fd
#         $DRY_RUN_CMD ${pkgs.git}/bin/git reset --hard HEAD
#         $DRY_RUN_CMD ${pkgs.git}/bin/git fetch origin
#         $DRY_RUN_CMD ${pkgs.git}/bin/git reset --hard origin/main
#        else
#         # If directory doesn't exist, clone it
#         $DRY_RUN_CMD ${pkgs.git}/bin/git clone git@github.com:cbaconnier/nvim.git "$nvimConfigPath" \
#           --config core.sshCommand="${pkgs.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_rsa"
#         fi
#     '';
#
#     makeNvimConfigWritable = lib.hm.dag.entryAfter ["cloneNvimConfig"] ''
#       $DRY_RUN_CMD chmod -R u+w "${config.home.homeDirectory}/.config/nvim"
#     '';
#   };

home.activation = {
  cloneNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    nvimConfigPath="${config.home.homeDirectory}/.config/nvim"

    # Check if nvim directory exists and has a git repo
    if [ ! -d "$nvimConfigPath" ] || [ ! -d "$nvimConfigPath/.git" ]; then

      # Clone the repository
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
        --config core.sshCommand="${pkgs.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_rsa" \
        git@github.com:cbaconnier/nvim.git "$nvimConfigPath"
      
      $DRY_RUN_CMD chmod -R u+w "${config.home.homeDirectory}/.config/nvim"

    fi
  '';
  };


}

