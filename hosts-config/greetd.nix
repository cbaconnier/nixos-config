{ pkgs, inputs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd 'uwsm start ${
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
          }/bin/Hyprland'";
        user = "greeter";
      };
    };
  };
  environment.systemPackages = with pkgs; [ tuigreet ];
}
