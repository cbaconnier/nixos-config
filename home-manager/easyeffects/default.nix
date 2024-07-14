{ pkgs,... }:

# https://home-manager-options.extranix.com/?query=easyeffects&release=master
# Require dconf to be enabled

{

  services.easyeffects = {
   enable = true;
   preset =  "masc_voice_noise_reduction";
  };
  
 # source of the preset: https://gist.github.com/rlopzc/44e4db5d4936f05a07e345d2fd9c4617:
 # needs to be added manually to easyeffects (?)
 home.file = {
  ".config/easyeffects/input/masc_voice_noise_reduction.json".source = ./masc_voice_noise_reduction.json;
 };

}
