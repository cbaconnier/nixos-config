{ ... }:

{
  xdg.configFile."xfce4/helpers.rc".text = ''
    TerminalEmulator=kitty
    TerminalEmulatorDismissed=false
  '';

  xdg.configFile."Thunar/accels.scm".text = ''
    (gtk_accel_path "<Actions>/ThunarWindow/view-side-pane-tree" "<Primary><Shift>e")
    (gtk_accel_path "<Actions>/ThunarWindow/view-side-pane-shortcuts" "<Primary>e")
  '';
}
