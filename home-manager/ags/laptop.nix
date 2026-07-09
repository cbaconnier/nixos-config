{ ... }:

{
  imports = [ ./. ];

  programs.agsAudio = {
    speakers = {
      ignore = [
        "alsa_output.pci-0000_c7_00.1.HiFi__HDMI1__sink"
        "alsa_output.pci-0000_c7_00.1.HiFi__HDMI2__sink"
        "alsa_output.pci-0000_c7_00.1.HiFi__HDMI3__sink"
        "alsa_output.pci-0000_c7_00.1.HiFi__HDMI4__sink"
        "alsa_output.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo" # Rode NT OUT
      ];
      rename = {
        "alsa_output.pci-0000_c7_00.6.HiFi__Speaker__sink" = "Speakers";
        "alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00203568-00.analog-stereo" =
          "Edifier";
        "alsa_output.usb-Lenovo_ThinkPad_Thunderbolt_4_Dock_USB_Audio_000000000000-00.analog-stereo" =
          "Dock";
        "alsa_output.pci-0000_c7_00.6.HiFi__Headphones__sink" = "Headphones";
      };
    };
    microphones = {
      ignore = [
        "alsa_input.usb-Lenovo_ThinkPad_Thunderbolt_4_Dock_USB_Audio_000000000000-00.mono-fallback"
        "alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00203568-00.analog-stereo"
      ];
      rename = {
        "alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo" =
          "Rode NT USB";
        "alsa_input.pci-0000_c7_00.6.HiFi__Mic1__source" = "Laptop intégré";
        "alsa_input.pci-0000_c7_00.6.HiFi__Mic2__source" = "Laptop jack";
      };
    };
  };
}
