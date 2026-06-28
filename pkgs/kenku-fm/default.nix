{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libnotify,
  libpulseaudio,
  libsecret,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxshmfence,
}:

stdenv.mkDerivation rec {
  pname = "kenku-fm";
  version = "1.5.5";

  src = fetchurl {
    url = "https://github.com/owlbear-rodeo/kenku-fm/releases/download/v${version}/kenku-fm_${version}_amd64.deb";
    sha256 = "0vrvvh8jmi2nqlljqyq6cbd7i3bwm4czz86pzv27f18mwsjl6fm0";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libnotify
    libsecret
    libxkbcommon
    mesa # libgbm
    nspr
    nss
    pango
    systemd # libudev
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
  ];

  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile $src | tar --no-same-permissions --no-same-owner -x
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share

    cp -r usr/lib/kenku-fm $out/lib/kenku-fm
    cp -r usr/share/applications $out/share/applications
    cp -r usr/share/pixmaps $out/share/pixmaps

    makeWrapper "$out/lib/kenku-fm/kenku-fm" "$out/bin/kenku-fm" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Online tabletop audio sharing for Discord";
    homepage = "https://kenku.fm";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "kenku-fm";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
