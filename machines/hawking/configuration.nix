{ self, ... }:
{ config, pkgs, lib, ... }:

{
  services.qemuGuest.enable = true;

  paul = {



    common-server.enable = true;
    systemd-boot.enable = true;
    #nvidia.enable = true;

    nginx.enable = true;
    nginx.enableGeoIP = true;

    # Exposed Services
    authentik = {
      enable = true;
      enableNginx = true;
      enableLdap = true;
      openFirewall = true;
    };
    librespeedtest = {
      enable = true;
      enableNginx = true;
    };
    jellyfin = {
      enable = true;
      enableNginx = true;
      enableQuickSync = true;
    };
    jellyseerr = {
      enable = true;
      enableNginx = true;
    };
    immich = {
      enable = true;
      enableNginx = true;
    };
    audiobookshelf = {
      #enable = true;
      #enableNginx = true;
    };

    # Local Services
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
    readarr = {
      #enable = true;
      #openFirewall = true;
    };
    homepage-dashboard = {
      enable = true;
      enableNginx = true;
    };
    thelounge = {
      enable = true;
      openFirewall = true;
    };
    plex = {
      enable = true;
      openFirewall = true;
    };

    minecraft-servers = {
      ftb-skies = {
        enable = true;
        enableDyndns = true;
      };
    };
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  services.netdata.enable = true;

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "hawking";
    tempAddresses = "disabled";
    firewall = {
      allowedTCPPorts = [
        80 # http
        443 # https
        19999 # netdata
      ];
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--accept-dns=false" "--advertise-exit-node" ];
  };

  # Running fstrim weekly is a good idea for VMs.
  # Empty blocks are returned to the host, which can then be used for other VMs.
  # It also reduces the size of the qcow2 image, which is good for backups.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.nginx.virtualHosts."${config.paul.private.domains.egg}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "302 https://www.youtube.com/watch?v=dQw4w9WgXcQ";
    };
  };

  services.nginx.virtualHosts."${config.paul.private.domains.filebrowser}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.222:30044";
      geo-ip = true;
    };
  };

  services.nginx.virtualHosts."${config.paul.private.domains.shark_base}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "302 https://www.youtube.com/watch?v=ys6yIhWwEyI";
    };
  };


  paul.dyndns.domains = [
    config.paul.private.domains.egg
    config.paul.private.domains.filebrowser
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
