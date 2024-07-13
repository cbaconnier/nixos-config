{ pkgs, ...}:

let
    noise-suppression-for-voice = pkgs.callPackage  ./../packages/noise-suppression-for-voice/default.nix { };
in 
{
  environment.systemPackages = with pkgs; [
   noise-suppression-for-voice
  ];

 

}

