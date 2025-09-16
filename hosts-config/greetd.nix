{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd 'Hyprland >/dev/null 2>&1'";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [ tuigreet ];
}
