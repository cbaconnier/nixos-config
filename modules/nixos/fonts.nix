{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      twitter-color-emoji
      font-awesome
      powerline-fonts

      # Tabler icons are not packaged in nixpkgs: take the font from the npm webfont release
      (stdenvNoCC.mkDerivation {
        pname = "tabler-icons-font";
        version = "3.52.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@tabler/icons-webfont/-/icons-webfont-3.52.0.tgz";
          hash = "sha512-Kdr77t4sXa1YiznEcj8aFsqDTPbCjTNV2V5c3UccXa1hFm6n4qrsnMMXHtEX5puBbXmcrTZcUgJyOVrhk6+u0A==";
        };
        sourceRoot = "package";
        installPhase = "install -Dm444 dist/fonts/tabler-icons.ttf $out/share/fonts/truetype/tabler-icons.ttf";
      })

      # https://www.reddit.com/r/NixOS/comments/1h1nc2a/nerdfonts_has_been_separated_into_individual_font/
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono

      carlito
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      source-code-pro
      source-han-mono
      source-han-sans
      source-han-serif
      wqy_zenhei
    ];
  };
}
