{
  lib,
  hyprland,
  fetchFromGitHub,
  cmake,
  pkg-config,
}:

hyprland.stdenv.mkDerivation (finalAttrs: {
  pname = "glasscope";
  version = "0-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "Horizon0427";
    repo = "Glasscope";
    rev = "ebd2d02e93e476d72ba30d7bb932fc3e34339e6b";
    hash = "sha256-BdK8MOzCdRKpz15jZJf8GaVBKOou3BxFuxTDkS4kqfo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ hyprland ] ++ hyprland.buildInputs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv glasscope.so $out/lib/lib${finalAttrs.pname}.so

    runHook postInstall
  '';

  meta = {
    description = "Liquid-glass magnifier that follows the pointer on Hyprland";
    homepage = "https://github.com/Horizon0427/Glasscope";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
  };
})
