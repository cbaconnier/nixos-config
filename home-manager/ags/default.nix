{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  agsPackage = inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cfg = config.programs.agsAudio;

  deviceRules = lib.types.submodule {
    options = {
      ignore = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "alsa_output.pci-0000_c7_00.1.HiFi__HDMI1__sink" ];
        description = "PipeWire node.name values to hide from the picker.";
      };
      rename = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Map of PipeWire node.name to the label shown in the picker.";
      };
    };
  };
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  options.programs.agsAudio = {
    speakers = lib.mkOption {
      type = deviceRules;
      default = { };
      description = "Output device rules for the ags audio picker.";
    };
    microphones = lib.mkOption {
      type = deviceRules;
      default = { };
      description = "Input device rules for the ags audio picker.";
    };
  };

  config = {
    programs.ags = {
      enable = true;
      configDir = ./src;
      extraPackages = with pkgs; [
        # inputs.astal.packages.${pkgs.system}.battery
        fzf
      ];
    };

    xdg.configFile."ags-audio.json".text = builtins.toJSON {
      speakers = cfg.speakers;
      microphones = cfg.microphones;
    };

    home.file."nixos-config/home-manager/ags/src/node_modules/ags".source =
      "${agsPackage}/share/ags/js";
    home.file."nixos-config/home-manager/ags/src/node_modules/gnim".source =
      "${agsPackage}/share/ags/js/node_modules/gnim";
  };
}
