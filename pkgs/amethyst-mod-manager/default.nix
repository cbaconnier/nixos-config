# From https://github.com/NixOS/nixpkgs/pull/547296, not yet merged upstream
{
  _7zz,
  bash,
  cabextract,
  fetchFromGitHub,
  glib,
  lib,
  meson,
  ninja,
  python3Packages,
  qt6,
  winetricks,
  xdg-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "amethyst-mod-manager";
  version = "2.2.0";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ChrisDKN";
    repo = "Amethyst-Mod-Manager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1ZahPn/eBTXWV3GR17PzhzVnp+xx2QDJQkThjzmcpDY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dependencies = with python3Packages; [
    # requirements-vendor.txt
    py7zr
    pillow
    lz4
    zstandard
    requests
    keyring
    jeepney
    msgpack
    bsdiff4
    cryptography
    secretstorage
    certifi
    # not in requirements-vendor.txt
    libloot
    pyside6
  ];

  postPatch = ''
    patchShebangs src/version.py

    substituteInPlace src/Utils/protontricks.py \
        --replace-fail '_get_tools_dir() / "winetricks"' 'Path("${lib.getExe winetricks}")' \
        --replace-fail '_get_tools_dir() / "cabextract"' 'Path("${lib.getExe cabextract}")'

    substituteInPlace src/Nexus/nxm_handler.py \
        --replace-fail \
            "f'{cls._quote_if_needed(exe)} {cls._quote_if_needed(script)} --nxm %u'" \
            "'amethyst-mod-manager --nxm %u'"
  '';

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --suffix PATH : "${
          lib.makeBinPath [
            _7zz
            bash
            glib # gio, gdbus
            python3Packages.python
            xdg-utils # xdg-open, xdg-mime, xdg-settings
          ]
        }"
    )
    wrapQtApp $out/bin/amethyst-mod-manager ''${makeWrapperArgs[@]}
    wrapProgram $out/bin/amethyst-mod-manager-cli ''${makeWrapperArgs[@]}
    rm -r $out/share/metainfo
  '';

  # no tests
  doCheck = false;

  pythonImportsCheck = [
    "cli"
    "run_qt"
  ];

  __structuredAttrs = true;

  meta = {
    description = "Linux native mod manager for a variety of games";
    homepage = "https://github.com/ChrisDKN/Amethyst-Mod-Manager";
    changelog = "https://github.com/ChrisDKN/Amethyst-Mod-Manager/blob/${finalAttrs.src.tag}/Changelog.txt";
    license = lib.licenses.gpl3Only;
    mainProgram = "amethyst-mod-manager";
    platforms = lib.platforms.linux;
  };
})
