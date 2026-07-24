{
  lib,
  stdenv,
  fetchurl,
  appimage-run,
  makeWrapper,
  makeDesktopItem,
}:

let
  pname = "amsel-suite";
  version = "1.9.2";

  src = fetchurl {
    url = "https://github.com/OllamTechnologies/launcher-releases/releases/download/v${version}/Amsel.Suite-${version}-x64.AppImage";
    sha256 = "sha256:a57e69bc726864be834b4d17efd7b6d796022ff4a15d46b9ffe118a9ff0ccab1";
  };

  icon = ./icon.png;

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Amsel Suite";
    exec = "${pname}-wrapped %U";
    icon = pname;
    categories = [
      "Game"
      "Office"
    ];
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/bin \
      $out/share/applications \
      $out/share/icons/hicolor/256x256/apps

    cp $src $out/bin/${pname}
    chmod +x $out/bin/${pname}

    cp ${icon} $out/share/icons/hicolor/256x256/apps/${pname}.png
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/

    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/${pname}-wrapped \
      --add-flags "$out/bin/${pname}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Amsel Suite launcher";
    homepage = "https://github.com/OllamTechnologies/launcher-releases";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "${pname}-wrapped";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
