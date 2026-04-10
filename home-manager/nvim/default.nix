{
  config,
  pkgs,
  lib,
  ...
}:
let
  phpantom_lsp = pkgs.stdenv.mkDerivation rec {
    pname = "phpantom_lsp";
    version = "0.7.0";

    src = pkgs.fetchurl {
      url = "https://github.com/AJenbo/phpantom_lsp/releases/download/${version}/phpantom_lsp-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256:a593da7e62adcef3ec63ca273f855ae269d55f2eed1f5d01ea0e3347f1597a5c";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 phpantom_lsp $out/bin/phpantom_lsp
    '';
  };
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    withRuby = false;
    withPython3 = false;

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
      phpantom_lsp
      # intelephense
      phpactor

      # Web Development
      typescript-language-server
      vscode-langservers-extracted
      tailwindcss-language-server
      vtsls

      # Formatters
      prettier
      stylua
      php83Packages.php-cs-fixer
      nixfmt
      # pint -- this one use ./vendor/bin/pint

      # Additional useful tools
      fd

      # Other LSP
      nixd
      rust-analyzer

      # Required for image.nvim
      imagemagick
    ];
  };

  # Clone my nvim configuration with write access when not already present.
  home.activation = {
    cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      nvimConfigPath="${config.home.homeDirectory}/.config/nvim"

      # Check if nvim directory exists and has a git repo
      if [ ! -d "$nvimConfigPath" ] || [ ! -d "$nvimConfigPath/.git" ]; then

        # Clone the repository
        run ${pkgs.git}/bin/git clone \
          --config core.sshCommand="${pkgs.openssh}/bin/ssh -i ${config.home.homeDirectory}/.ssh/id_rsa" \
          git@github.com:cbaconnier/nvim.git "$nvimConfigPath"
        
        run chmod -R u+w "${config.home.homeDirectory}/.config/nvim"

      fi
    '';
  };

}
