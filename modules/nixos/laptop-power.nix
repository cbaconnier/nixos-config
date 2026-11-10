{ pkgs, ... }:
{
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

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
      # https://linrunner.de/tlp/settings/bc-vendors.html#lenovo-thinkpads
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # Optimizations
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;

      # Disable USB autosuspend for certain devices if needed
      # USB_DENYLIST = "1234:5678";  # Add device IDs that shouldn't be suspended
    };
  };

  # Auto-suspend when idle
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      # HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = "30min";
    };
  };

  # issue(2026-11-09): waking the laptop (dock power button, lid open) sometimes
  # shuts it down. tiny_power_button turns the EC's wake-time "power button" event
  # into SIGRTMIN+4 (poweroff) for PID 1, bypassing logind's HandlePowerKey.
  boot.blacklistedKernelModules = [ "tiny_power_button" ];

  # Audit kept to catch any userspace sender of SIGRTMIN+4 to PID 1 if it still happens.
  # Run `sudo ausearch -k sigpoweroff` to read the logs.
  security.auditd.enable = true;
  security.audit = {
    enable = true;
    rules = [
      "-a always,exit -F arch=b64 -S kill -S tkill -S rt_sigqueueinfo -S pidfd_send_signal -F a1=38 -k sigpoweroff"
      "-a always,exit -F arch=b64 -S tgkill -S rt_tgsigqueueinfo -F a2=38 -k sigpoweroff"
    ];
  };

  # System packages for power monitoring
  environment.systemPackages = with pkgs; [
    acpi
    powertop
  ];
}
