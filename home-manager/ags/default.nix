{ pkgs, ... }:

let
  ags-config = pkgs.stdenv.mkDerivation {
    name = "ags-config";
    src = ./.; 
    buildInputs = [ pkgs.bun ];
    buildPhase = ''
      mkdir -p $out
      ${pkgs.bun}/bin/bun build ./src/main.ts \
        --outdir $out \
        --external "resource://*" \
        --external "gi://*"
    '';
    installPhase = ''
      cp -r $src/src $out/
      cp $src/style.css $out/
      cp $src/tsconfig.json $out/
      ln -s ${pkgs.ags}/share/com.github.Aylur.ags/types $out/types
      mv $out/main.js $out/config.js
    '';
  };
in
{
  home.packages = with pkgs; [
    bun
  ];

  home.file = {
    ".config/ags".source = ags-config;
  };

  # Ensure the tmp directory exists
  home.activation = {
    createAgsTmpDir = ''
      mkdir -p /tmp/ags/js
    '';
  };
}
