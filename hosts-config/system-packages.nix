{ pkgs, ...}:
{
 # List packages installed in system profile. To search, run:
 # $ nix search wget
 environment.systemPackages = with pkgs; [
   vim 
   wget
   curl 
   git
   zsh
   xboxdrv # xbox controller driver
 ];
}
