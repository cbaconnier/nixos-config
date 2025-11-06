{ pkgs, ... }:

# Power management for ThinkPad Z16
{
  # Enable laptop power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Battery optimization
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      # CPU boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Platform profiles
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # Runtime power management for PCI(e) devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";

      # Battery care (limits charge to extend battery life)
      # Uncomment and adjust values if needed
      # START_CHARGE_THRESH_BAT0 = 75;
      # STOP_CHARGE_THRESH_BAT0 = 80;

      # Disable USB autosuspend for certain devices if needed
      # USB_DENYLIST = "1234:5678";  # Add device IDs that shouldn't be suspended
    };
  };

  # Auto-suspend when idle
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "suspend";

    extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=30min
    '';
  };

  # Enable thermald for thermal management
  services.thermald.enable = true;

  # System packages for power monitoring
  environment.systemPackages = with pkgs; [ acpi powertop tlp ];

  # Note: If using power-profiles-daemon instead of TLP, use this:
  # services.power-profiles-daemon.enable = true;
  # (Comment out the tlp section above)
}
