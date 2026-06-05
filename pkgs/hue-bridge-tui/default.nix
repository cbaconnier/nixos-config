{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "hue-bridge-tui";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "MoAlshatti";
    repo = "hue-bridge-TUI";
    rev = "v0.1.3";
    hash = "sha256-zEUVpovDcoZS5+UIXrNxkVzwFoa0ds/tVN9tTA0syA0=";
  };

  vendorHash = "sha256-5jttNcSEuDfj8OnqQUVP+eYzb6Fi1CN9Xe/W/oLsxSU=";

  subPackages = [ "cmd/huecli" ];

  meta = with lib; {
    description = "A TUI application for controlling your Philips hue lights in the terminal ";
    homepage = "https://github.com/MoAlshatti/hue-bridge-TUI";
    mainProgram = "huecli";
  };
}
