{ ... }:

# https://home-manager-options.extranix.com/?query=easyeffects&release=master
# Require dconf to be enabled

{

  services.easyeffects = {
    enable = true;
  };

  home.file = {
    ".local/share/easyeffects/input/masc_voice_noise_reduction.json".source =
      ./input-presets/masc_voice_noise_reduction.json;
    ".local/share/easyeffects/output/thinkpad_z13_gen1_output.json".source =
      ./output-presets/thinkpad_z13_gen1_output.json;
    ".local/share/easyeffects/output/blank_output.json".source = ./output-presets/blank_output.json;
    ".local/share/easyeffects/output/Beyerdynamic DT 770 Pro (80 Ohm).json".source =
      ./output-presets + "/Beyerdynamic DT 770 Pro (80 Ohm).json";

    ".local/share/easyeffects/autoload/output/alsa_output.pci-0000_c7_00.6.HiFi__Speaker__sink:Speaker.json".source =
      ./output-autoload/laptop.json;
    ".local/share/easyeffects/autoload/output/alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00203568-00.analog-stereo:Speakers.json".source =
      ./output-autoload/edifier-laptop.json;
    ".local/share/easyeffects/autoload/output/alsa_output.pci-0000_c7_00.6.HiFi__Headphones__sink:Headphones.json".source =
      ./output-autoload/dt770pro-laptop.json;

    ".local/share/easyeffects/autoload/input/alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo:Microphone.json".source =
      ./input-autoload/rode-laptop.json;
  };

}
