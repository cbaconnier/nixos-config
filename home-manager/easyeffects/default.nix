{ pkgs,... }:

# https://home-manager-options.extranix.com/?query=easyeffects&release=master
# Require dconf to be enabled

{

  services.easyeffects = {
   enable = true;
   preset = "masc_voice_noise_reduction";
  };

  home.file = {
   ".config/easyeffects/input/masc_voice_noise_reduction.json".source = ./masc_voice_noise_reduction.json;
   ".local/share/easyeffects/input/masc_voice_noise_reduction.json".source = ./masc_voice_noise_reduction.json;
  };

}
