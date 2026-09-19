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
  version = "1.9.2";

  src = fetchurl {
    url = "https://github.com/OllamTechnologies/launcher-releases/releases/download/v${finalAttrs.version}/Amsel.Suite-${finalAttrs.version}-x64.AppImage";
    hash = "sha256-pX5pvHJoZL6DS00X79e215YCL/ShXUa5/+EYqf8MyrE=";
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
