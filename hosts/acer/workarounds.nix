# Power-management workarounds.
#
# Resume from sleep and hibernation is unreliable, so both are disabled,
# and lid, key and idle events no longer trigger them.
#
# To prevent random, unreproducible hangs, GFXOFF, deep CPU idle states
# and IOMMU translation are also disabled.

{ lib, pkgs, ... }:

{
  systemd = {
    sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
      suspend-then-hibernate.enable = false;
    };
  };

  services = {
    logind.settings.Login = {
      HandleLidSwitch = "lock";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";
      HandleSuspendKey = "ignore";
      HandleSuspendKeyLongPress = "ignore";
      HandleHibernateKey = "ignore";
      HandleHibernateKeyLongPress = "ignore";
      IdleAction = "ignore";
    };
    upower.criticalPowerAction = lib.mkForce "PowerOff";
  };

  boot.kernelParams = [
    "amdgpu.ppfeaturemask=0xfff73fff"
    "mem_sleep_default=s2idle"
    "iommu=pt"
    "idle=nomwait"
  ];
  powerManagement = {
    powerDownCommands = "${pkgs.kmod}/bin/modprobe -r ath10k_pci";
    resumeCommands   = "${pkgs.kmod}/bin/modprobe ath10k_pci";
  };
}
