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

      # nodePackages.vtsls 
      # waiting for one or the other
      # - https://github.com/NixOS/nixpkgs/pull/319501
      # - https://github.com/NixOS/nixpkgs/pull/347284

      # Formatters
      nodePackages.prettier
      blade-formatter
      stylua
      php83Packages.php-cs-fixer
      # pint -- this one use ./vendor/bin/pint
      

      # Additional useful tools
      fd

      # Other LSP
      nixd
    ];
  };
 
  # Clone my nvim configuration with write access when not already present.
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

