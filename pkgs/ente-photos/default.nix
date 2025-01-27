{ lib, stdenv, fetchurl, appimage-run, makeWrapper }:

# Get the sha256 run : 
# 
# nix-prefetch-url https://github.com/ente-io/photos-desktop/releases/download/v1.7.8/ente-1.7.8-x86_64.AppImage
#
# Or use lib.fakeSha256

stdenv.mkDerivation rec {
  pname = "ente-photos";
  version = "1.7.8";

  src = fetchurl {
    url =
      "https://github.com/ente-io/photos-desktop/releases/download/v${version}/ente-${version}-x86_64.AppImage";
    sha256 = "0kxbp06vni9sfwh79s35xsf9bwzbckfr9zwa78ncnhlv9ihbv2ki";
  };

  icon = fetchurl {
    url =
      "https://raw.githubusercontent.com/ente-io/ente/refs/heads/main/desktop/build/icon.png";
    sha256 = "1kv9fk2y9rrwldba0ns4p7z3aygzffq21fgn3gfymx6ij2kfjqsh";
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
    Name=Ente Photos
    Exec=$out/bin/${pname}-wrapped    
    Icon=${pname}
    Type=Application
    Categories=Graphics;Photography;
    EOF
  '';

  meta = with lib; {
    description = "Ente Photos Desktop AppImage";
    homepage = "https://github.com/ente-io/photos-desktop";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "${pname}-wrapped";
  };
}
