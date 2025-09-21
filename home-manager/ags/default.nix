{ inputs, pkgs, ... }: {
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
}
