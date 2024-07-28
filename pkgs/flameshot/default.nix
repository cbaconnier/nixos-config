{ mkDerivation
, lib
, fetchFromGitHub
, qtbase
, cmake
, qttools
, qtsvg
, nix-update-script
, fetchpatch
, kguiaddons
, pkgs
, grim 
, wrapQtAppsHook
}:

mkDerivation rec {
  pname = "flameshot";
  version = "unstable-2024-07-28";

  src = fetchFromGitHub {
    owner = "flameshot-org";
    repo = "flameshot";
    rev = "ccb5a27b136a633911b3b1006185530d9beeea5d";
    sha256 = "JIXsdVUR/4183aJ0gvNGYPTyCzX7tCrk8vRtR8bcdhE=";
  };

  patches = [
    # https://github.com/flameshot-org/flameshot/pull/3166
    (fetchpatch {
      name = "10-fix-wayland.patch";
      url = "https://github.com/flameshot-org/flameshot/commit/5fea9144501f7024344d6f29c480b000b2dcd5a6.patch";
      sha256 = "sha256-SnjVbFMDKD070vR4vGYrwLw6scZAFaQA4b+MbI+0W9E=";
    })
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  cmakeFlags = [
    "-DUSE_WAYLAND_CLIPBOARD=ON"
    "-DUSE_WAYLAND_GRIM=ON"
  ];

  nativeBuildInputs = [ cmake qttools qtsvg ];
  buildInputs = [ qtbase kguiaddons grim ];
  
  preFixup = ''
    qtWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ grim ]})
  '';

  meta = with lib; {
    description = "Powerful yet simple to use screenshot software";
    homepage = "https://github.com/flameshot-org/flameshot";
    mainProgram = "flameshot";
    maintainers = with maintainers; [ scode oxalica ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
