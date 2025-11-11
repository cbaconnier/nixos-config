{ inputs, pkgs, ... }:
let agsPackage = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./src;
    extraPackages = with pkgs;
      [
        # inputs.astal.packages.${pkgs.system}.battery
        fzf
      ];
  };

  home.file."nixos-config/home-manager/ags/src/node_modules/ags".source =
    "${agsPackage}/share/ags/js";
  home.file."nixos-config/home-manager/ags/src/node_modules/gnim".source =
    "${agsPackage}/share/ags/js/node_modules/gnim";
}
