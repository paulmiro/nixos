{
  config,
  lib,
  useful-api,
  ...
}:
{
  paul = {
    common-server.enable = true;
    grub.enable = true;

    tailscale = {
      enable = true;
      exitNode = true;
    };

    nginx = {
      enable = true;
      enableGeoIP = true;
    };

    uptime-kuma = {
      enable = true;
      enableNginx = true;
    };

    gotify = {
      enable = true;
      enableNginx = true;
    };

    microsocks = {
      enable = true;
      openFirewall = true;
    };
  };

  clan.core.networking.targetHost = "morse.${config.paul.private.domains.tailnet}";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking = {
    tempAddresses = "disabled";
    firewall = {
      allowedTCPPorts = [ ];
    };
    useDHCP = lib.mkDefault true;
  };

  services.nginx.virtualHosts."paulmiro.de" = {
    enableACME = true;
    forceSSL = true;
    enableDyndns = true;
    locations."/" = {
      return = "301 https://github.com/paulmiro";
    };
  };

  services.nginx.virtualHosts."api.${config.paul.private.domains.base}" = {
    enableACME = true;
    forceSSL = true;
    enableDyndns = true;
    locations."/" = {
      proxyPass = "http://localhost:19190";
    };
  };

  systemd.services.useful-api = {
    description = "A very useful API";
    after = [
      "network.target"
    ];
    serviceConfig = {
      ExecStart = "${useful-api.packages.x86_64-linux.default}/bin/useful-api";
    };
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # During boot, resize the root partition to the size of the disk.
  # This makes upgrading the size of the vDisk easier.
  fileSystems."/".autoResize = true;
  boot.growPartition = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # MiB
    }
  ];

  boot = {
    loader = {
      timeout = 10;
      grub = {
        device = "/dev/vda";
        configurationLimit = 10;
      };
    };
  };
}
