{
  lib,
  appimageTools,
  fetchurl,
  makeDesktopItem,
}:

let
  pname = "amsel-suite";

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Amsel Suite";
    exec = "${pname} %U";
    icon = pname;
    categories = [
      "Game"
      "Office"
    ];
  };
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname;
  version = "1.14.0";

  src = fetchurl {
    url = "https://github.com/OllamTechnologies/launcher-releases/releases/download/v${finalAttrs.version}/AmselSuite-linux-x64.AppImage";
    hash = "sha256:a857c1e10ef7ed0ab339663ddc09254c1b0036701cec6ffa93d44a764abfe3c5";
  };

  extraInstallCommands = ''
    install -Dm444 ${./icon.png} $out/share/icons/hicolor/256x256/apps/${pname}.png
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
  '';

  meta = {
    description = "Amsel Suite launcher";
    homepage = "https://github.com/OllamTechnologies/launcher-releases";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
})
