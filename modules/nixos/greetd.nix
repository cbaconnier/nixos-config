{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd 'start-hyprland > /tmp/hyprland-session.log 2>&1'";
        user = "greeter";
      };
    };
  };
  environment.systemPackages = with pkgs; [ tuigreet ];
}
