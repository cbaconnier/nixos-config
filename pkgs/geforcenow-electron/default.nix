{ lib, stdenv, fetchurl, appimage-run, makeWrapper }:

# Get the sha256 run : 
# 
# nix-prefetch-url https://github.com/hmlendea/gfn-electron/releases/download/v2.1.2/geforcenow-electron_2.1.2_linux.AppImage
#
# Or use lib.fakeSha256

stdenv.mkDerivation rec {
  pname = "geforcenow-electron";
  version = "2.1.2";

  src = fetchurl {
    url = "https://github.com/hmlendea/gfn-electron/releases/download/v${version}/geforcenow-electron_${version}_linux.AppImage";
    sha256 = "10rs8lcz5x8mdw7j2lz1gdn0kadil186zxd9k6lcnv6g0cdha6yj";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/hmlendea/gfn-electron/master/icon.png";
    sha256 = "185phacnibmn63qhrnkffgjdp8bhma0sp86ai8fya9ir0yxx8ajq";  
  };


nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p \
      $out/bin \
      $out/share/applications \
      $out/share/icons/hicolor/256x256/apps
    
    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}

    cp $icon $out/share/icons/hicolor/256x256/apps/${pname}.png

    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/${pname}-wrapped \
      --add-flags "$out/bin/${pname}"

    # Create a .desktop file
    cat > $out/share/applications/${pname}.desktop << EOF
    [Desktop Entry]
    Name=GeForce NOW Electron
    Exec=$out/bin/${pname}-wrapped    
    Icon=${pname}
    Type=Application
    Categories=Game;
    EOF
  '';

  meta = with lib; {
    description = "GeForce NOW Electron AppImage";
    homepage = "https://github.com/hmlendea/gfn-electron";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "${pname}-wrapped";
  };
}
