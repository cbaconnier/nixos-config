{ ... }:

{
  imports = [ ./. ];

  # node.name via: wpctl inspect <id> | grep node.name
  # programs.agsAudio.speakers.rename = { "alsa_output...." = "Casque"; };
}
