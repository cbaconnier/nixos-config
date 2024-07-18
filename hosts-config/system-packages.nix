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
 ];
 
services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

}
