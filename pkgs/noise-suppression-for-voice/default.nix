{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, freetype
, libX11
, libXcursor
, libXinerama
, libXrandr
, libXext
, libXi
, libXcomposite
, alsa-lib
, jack2
}:

# getting the hash: nix-prefetch-git https://github.com/werman/noise-suppression-for-voice.git --rev v1.10
# nix-prefetch-git https://github.com/werman/noise-suppression-for-voice.git --rev v1.10 

stdenv.mkDerivation rec {
  pname = "noise-suppression-for-voice";
  version = "1.10";

  outputs = [ "out" ];

  src = fetchFromGitHub {
    owner = "werman";
    repo = "noise-suppression-for-voice";
    rev = "v${version}";
    hash = "sha256-HtWDwKZ4UFLE7k93ONcubrMmvFYvDKgZwFSkqgXiCXY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [
    freetype
    libX11
    libXcursor
    libXinerama
    libXrandr
    libXext
    libXi
    libXcomposite
    alsa-lib
    jack2
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BUILD_TYPE=None"
   # "-DBUILD_VST2_PLUGIN=OFF"
   # "-DBUILD_VST3_PLUGIN=OFF"
   # "-DBUILD_LV2_PLUGIN=ON"
   # "-DBUILD_LADSPA_PLUGIN=ON"
  ];

  #NIX_CFLAGS_COMPILE = "-I${libX11.dev}/include/X11/extensions";

  meta = with lib; {
    description = "A real-time noise suppression plugin for voice";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
