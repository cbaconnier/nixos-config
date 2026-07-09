{ ... }:

{
  imports = [ ./. ];

  # node.name via: wpctl list, wpctl inspect <id> | grep node.name
  programs.agsAudio = {
    speakers = {
      ignore = [
        "alsa_output.pci-0000_01_00.1.hdmi-stereo"
        "alsa_output.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo" # Rode NT OUT
        "easyeffects_sink"
      ];
      rename = {
        "alsa_output.pci-0000_00_1f.3.analog-stereo" = "Edifier | Headphones";
      };
    };
    microphones = {
      ignore = [
        "easyeffects_source"
      ];
      rename = {
        "alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo" =
          "Rode NT USB";
        "alsa_input.pci-0000_00_1f.3.analog-stereo" = "Headset";
      };
    };
  };
}
