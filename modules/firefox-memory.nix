{ lib, ... }:
{
  options.my.firefox.memoryHigh = lib.mkOption {
    type = lib.types.str;
    default = "4G";
    description = "Memory above which Firefox gets throttled and swapped out (systemd MemoryHigh=).";
  };

  config.home-manager.sharedModules = [
    ({ osConfig, ... }: {
      xdg.configFile."systemd/user/app-firefox\\x2desr@.service.d/memory.conf".text = ''
        [Service]
        MemoryHigh=${osConfig.my.firefox.memoryHigh}
      '';
    })
  ];
}
