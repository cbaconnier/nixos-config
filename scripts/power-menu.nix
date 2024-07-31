{ pkgs, ... }:

pkgs.writeShellScriptBin "power-menu" ''

run_rofi() {
    ${pkgs.rofi}/bin/rofi -theme ~/.config/rofi/config.rasi "$@"
}

chosen=$(printf "1\tShutdown\n2\tReboot\n3\tLogout\n4\tShutdown at" | \
     run_rofi -dmenu -i -p "Power Menu" \
    -kb-custom-1 "1" \
    -kb-custom-2 "2" \
    -kb-custom-3 "3" \
    -kb-custom-4 "4" \
    -selected-row 0)

rofi_exit=$?

get_shutdown_time() {
    run_rofi -dmenu \
         -p "Shutdown delay:" \
         -mesg "Examples: '+30' for 30 minutes, '22:00' for 22h00" \
         -theme-str 'inputbar {children: [prompt, entry];}' \
         -lines 0
}

execute_action() {
    case $1 in
        *"Shutdown")
            ${pkgs.systemd}/bin/shutdown now
            ;;
        *"Reboot")
            ${pkgs.systemd}/bin/reboot
            ;;
        *"Logout")
            ${pkgs.hyprland}/bin/hyprctl dispatch exit
            ;;
        *"Shutdown at")
	          shutdown_time=$(get_shutdown_time)
            if [ -n "$shutdown_time" ]; then
              ${pkgs.systemd}/bin/shutdown "$shutdown_time"
              if [[ "$shutdown_time" == +* ]]; then
                minutes=''${shutdown_time#+}
                ${pkgs.libnotify}/bin/notify-send "Shutdown Scheduled" "System will shutdown in $minutes minutes"
              else
                ${pkgs.libnotify}/bin/notify-send "Shutdown Scheduled" "System will shutdown at $shutdown_time"
              fi
            fi
            ;;
    esac
}

# Check if a custom key was pressed or if Enter was used
if [ $rofi_exit -ge 10 ] && [ $rofi_exit -le 13 ]; then
    # Custom key was pressed
    case $rofi_exit in
        10) execute_action "Shutdown" ;;
        11) execute_action "Reboot" ;;
        12) execute_action "Logout" ;;
        13) execute_action "Shutdown at" ;;
    esac
else
    # Enter was pressed, execute based on the selection
    notify-send "_ $chosen _"
    execute_action "$chosen"
fi
''
