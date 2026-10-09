{ pkgs, lib, ... }:

# Virtual voices: `systemctl --user start <voice>` creates the virtual mic <voice>_source.
# `voice-mode` starts one, makes it the default source and loads an empty EasyEffects
# preset, so EasyEffects monitors it and serves it to apps like any other mic.
#
#   raw mic -> filter-chain -> <voice>_source -> EasyEffects (empty preset) -> speakers / apps
#
# The mic is taken raw, not through EasyEffects: its gate would cut whispers and breaths.
let
  v = import ./lib.nix { inherit pkgs; };
  voices = {
    banshee = import ./banshee.nix v;
    dragon = import ./dragon.nix v;
    double-entity = import ./double-entity.nix v;
    storyteller = import ./storyteller.nix v;
  };
in
{
  systemd.user.services = lib.mapAttrs v.service voices;
}
