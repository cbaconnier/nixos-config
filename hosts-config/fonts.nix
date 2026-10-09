{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      twitter-color-emoji
      font-awesome
      powerline-fonts

      # Tabler icons are not packaged in nixpkgs: take the font from the npm webfont release
      (stdenvNoCC.mkDerivation {
        pname = "tabler-icons-font";
        version = "3.49.0";
        src = fetchurl {
          url = "https://registry.npmjs.org/@tabler/icons-webfont/-/icons-webfont-3.49.0.tgz";
          hash = "sha512-kWgnmEzo17dzQyMqRmlfj+TiGV0clLMYfUtKp2WG7M+TH5418o6fsoaSlrOTK3lwESg0xS7jVfOozYrR02Ryxw==";
        };
        sourceRoot = "package";
        installPhase = "install -Dm444 dist/fonts/tabler-icons.ttf $out/share/fonts/truetype/tabler-icons.ttf";
      })

      # https://www.reddit.com/r/NixOS/comments/1h1nc2a/nerdfonts_has_been_separated_into_individual_font/
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono

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
