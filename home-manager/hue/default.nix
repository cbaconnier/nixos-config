{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.hue;
in
{
  options.programs.hue.bridgeIp = lib.mkOption {
    type = lib.types.str;
    default = "192.168.1.98";
    description = "Hue bridge address read by hue-ctl and the quickshell lights panel.";
  };

  config = {
    # The API key itself comes from agenix at /run/agenix/hue-api-key.
    xdg.configFile."hue/bridge-ip".text = "${cfg.bridgeIp}\n";
  };
}
