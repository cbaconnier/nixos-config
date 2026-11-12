{
  config,
  pkgs,
  lib,
  ...
}:
let
  phpantom_lsp = pkgs.stdenv.mkDerivation rec {
    pname = "phpantom_lsp";
    version = "0.11.1";

    src = pkgs.fetchurl {
      url = "https://github.com/AJenbo/phpantom_lsp/releases/download/${version}/phpantom_lsp-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-kG3YEE1L+CqhxCJfuil6kP8c/wVS32Ne6Fj8Jy9EX8Y=";
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
      intelephense
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
      kdePackages.qtdeclarative # qmlls, qmlformat, qmllint

      # Required for snacks.nvim image rendering
      imagemagick
    ];
  };

  # Prevent home-manager from managing init.lua
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

  # Clone my nvim configuration into ~/Projects/cbaconnier/ and symlink it from ~/.config/nvim.
  home.activation = {
    cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      nvimRepoPath="${config.home.homeDirectory}/Projects/cbaconnier/nvim"
      nvimConfigPath="${config.home.homeDirectory}/.config/nvim"

      if [ ! -d "$nvimConfigPath/.git" ]; then
        if [ ! -d "$nvimRepoPath/.git" ]; then
          run mkdir -p "$(dirname "$nvimRepoPath")"
          run ${pkgs.git}/bin/git clone https://github.com/cbaconnier/nvim.git "$nvimRepoPath"
          run ${pkgs.git}/bin/git -C "$nvimRepoPath" remote set-url --push origin git@github.com:cbaconnier/nvim.git
          run chmod -R u+w "$nvimRepoPath"
        fi

        if [ ! -e "$nvimConfigPath" ]; then
          run ln -sfn "$nvimRepoPath" "$nvimConfigPath"
        fi
      fi
    '';
  };

}
