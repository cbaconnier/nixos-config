{ ... }:

# https://home-manager-options.extranix.com/?query=easyeffects&release=master
# Require dconf to be enabled

# Where to find EQ
# - oratory1990
# - https://autoeq.app

{

  services.easyeffects = {
    enable = true;
  };

  home.file = {
    ###### Presets ######

    # Input without effects, used by the virtual voices
    ".local/share/easyeffects/input/blank_input.json".source = ./input-presets/blank_input.json;

    # Input (Rode NT)
    ".local/share/easyeffects/input/rode-default.json".source = ./input-presets/rode/default.json;

    # Input (ATR2100x-USB)
    ".local/share/easyeffects/input/atr2100x-default.json".source =
      ./input-presets/atr2100x/default.json;

    # Output
    ".local/share/easyeffects/output/thinkpad_z13_gen1_output.json".source =
      ./output-presets/thinkpad_z13_gen1_output.json;
    ".local/share/easyeffects/output/blank_output.json".source = ./output-presets/blank_output.json;
    ".local/share/easyeffects/output/Beyerdynamic DT 770 Pro (80 Ohm).json".source =
      ./output-presets + "/Beyerdynamic DT 770 Pro (80 Ohm).json";

    ###### Autoload ######

    # Output
    ".local/share/easyeffects/autoload/output/alsa_output.pci-0000_c7_00.6.HiFi__Speaker__sink:Speaker.json".source =
      ./output-autoload/laptop.json; # Laptop speakers
    ".local/share/easyeffects/autoload/output/alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00203568-00.analog-stereo:Speakers.json".source =
      ./output-autoload/edifier-laptop.json; # Edifier USB speakers
    ".local/share/easyeffects/autoload/output/alsa_output.pci-0000_c7_00.6.HiFi__Headphones__sink:Headphones.json".source =
      ./output-autoload/dt770pro-laptop.json; # DT 770 Pro headphones

    # Input
    ".local/share/easyeffects/autoload/input/alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo:Microphone.json".source =
      ./input-autoload/rode-laptop.json; # Rode NT
    ".local/share/easyeffects/autoload/input/alsa_input.usb-Audio_Technica_Corp_ATR2100x-USB_Microphone-00.analog-stereo:Microphone.json".source =
      ./input-autoload/atr2100x-laptop.json; # ATR2100x-USB
  };

}
