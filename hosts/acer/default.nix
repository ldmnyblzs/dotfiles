{ config, pkgs, ... }:
{
  system.stateVersion = "26.05";

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "rtsx_usb_sdmmc" ];
      kernelModules = [ ];
      luks.devices = {
        root.device = "/dev/disk/by-partlabel/root";
        swap.device = "/dev/disk/by-partlabel/swap";
      };
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
    "/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
    };
    "/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };
    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };
  };
  
  swapDevices = [
    { device = "/dev/mapper/swap"; }
  ];

  security.rtkit.enable = true;

  networking = {
    hostName = "ldmnyblzs";
    networkmanager = {
      enable = true;
      ensureProfiles = {
        profiles.eduroam = {
          connection = {
            id = "eduroam";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            eap = "ttls;";
            phase2-auth = "pap";
            ca-cert = "${../common/certs/eduroam-ca-cert.crt}";
            identity = "105271@bme.hu";
            anonymous-identity = "105271@bme.hu";
          };
        };
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  services = {
    xserver.xkb.layout = "hu"; # this doesn't enable X11!
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    ddccontrol.enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      kate # use mg/Emacs instead
      dolphin # use mc/Krusader instead
      ark # use CLI/Krusader instead
      qrca
    ];
    systemPackages = with pkgs; [
      git
      mg
      mc
      # archives
      zip
      unzip
      _7zz
      unrar
      unar
      arj
      lhasa
      cpio
      libarchive
      dpkg
      rpm
    ];
    variables = {
      EDITOR = "mg";
      VISUAL = "mg";
    };
  };

  time.timeZone = "Europe/Budapest";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "hu_HU.UTF-8";
      LC_IDENTIFICATION = "hu_HU.UTF-8";
      LC_MEASUREMENT = "hu_HU.UTF-8";
      LC_MONETARY = "hu_HU.UTF-8";
      LC_NAME = "hu_HU.UTF-8";
      LC_NUMERIC = "hu_HU.UTF-8";
      LC_PAPER = "hu_HU.UTF-8";
      LC_TELEPHONE = "hu_HU.UTF-8";
      LC_TIME = "hu_HU.UTF-8";
    };
  };
  console.keyMap = "hu";

  users.users.ldmnyblzs = {
    isNormalUser = true;
    description = "Balazs Ludmany";
    extraGroups = [ "networkmanager" "wheel" config.hardware.i2c.group ];
  };

  virtualisation.vmVariant = {
    virtualisation = {
      # 16 GB available
      memorySize = 4096;
      # 6C/12T available
      cores = 4;
      qemu.options = [ "-device virtio-vga" ];
      # the laptop has 1920x1200 resolution
      # keep the 16x10 aspect ratio but smaller
      resolution = {
        x = 1280;
        y = 800;
      };
    };
    users.users = {
      root.password = "test";
      ldmnyblzs.password = "test";
    };
    security.sudo.wheelNeedsPassword = false;
  };
}
