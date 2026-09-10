{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.barAudio;

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
  options.programs.barAudio = {
    speakers = lib.mkOption {
      type = deviceRules;
      default = { };
      description = "Output device rules for the bar's audio picker.";
    };
    microphones = lib.mkOption {
      type = deviceRules;
      default = { };
      description = "Input device rules for the bar's audio picker.";
    };
  };

  config = {
    home.packages = [ pkgs.quickshell ];

    xdg.configFile."quickshell-audio.json".text = builtins.toJSON {
      speakers = cfg.speakers;
      microphones = cfg.microphones;
    };

    xdg.configFile."quickshell/default" = {
      source = ./src;
      recursive = true;
    };
  };
}
