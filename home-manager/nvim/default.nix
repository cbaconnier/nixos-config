{ inputs, config, pkgs, ... }: 

# https://github.com/nix-community/nix4nvchad
# https://github.com/cbaconnier/nvim

# Nvchad is installed with nix4nvchad 
# By using my nvim repo 
# See flake.nix

{
  imports = [
    inputs.nvchad4nix.homeManagerModule
  ];

programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      # PHP/Laravel Development
      nodePackages.intelephense
      # php-debug-adapter
      phpactor

      # Web Development
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
      tailwindcss-language-server

      # Additional useful tools
      ripgrep
      fd
      tree-sitter

      # Other LSP
       nixd
      # rust-analyzer
      # python3Packages.python-lsp-server
    ];

    # Enable home-manager to manage the config
    hm-activation = true;
    backup = false;

    # extraConfig = ''
    #   ${builtins.readFile ./lua/init.lua}
    # '';

  };
}

