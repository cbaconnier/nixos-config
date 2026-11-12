{ lib, ... }:
{
  programs.claude-code.settings.theme = lib.mkForce "dark";
}
