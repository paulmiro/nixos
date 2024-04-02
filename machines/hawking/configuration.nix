{ self, ... }:
{ config, pkgs, lib, ... }:

{
  services.qemuGuest.enable = true;

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    nvidia.enable = true;

    nginx.enable = true;
    nginx.enableGeoIP = true;

    # Exposed Services
    librespeedtest = {
      enable = true;
      enableNginx = true;
    };
    jellyfin = {
      enable = true;
      enableNginx = true;
    };
    jellyseerr = {
      enable = true;
      enableNginx = true;
    };
    immich = {
      enable = true;
      enableNginx = true;
    };
    authentik = {
      enable = true;
      openFirewall = true;
      enableNginx = true;
    };
    audiobookshelf = {
      #enable = true;
      enableNginx = true;
    };
    hoarder = {
      enable = true;
      enableNginx = true;
      openFirewall = true;
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
      openFirewall = true;
    };
    homepage = {
      #enable = true;
      openFirewall = true;
    };
    thelounge = {
      enable = true;
      openFirewall = true;
    };
    plex = {
      enable = true;
      openFirewall = true;
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

  environment.systemPackages = with pkgs; [ ];

  ### Temporary stuff (will be removed or moved to modules) ###
  services.nginx.virtualHosts."***REMOVED***" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "302 https://www.youtube.com/watch?v=dQw4w9WgXcQ";
    };
  };
  paul.dyndns.domains = [ "***REMOVED***" "***REMOVED***" "***REMOVED***" ];

  services.nginx.virtualHosts."***REMOVED***" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.222:30044";
      geo-ip = true;
    };
  };

  services.nginx.virtualHosts."***REMOVED***" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://192.168.178.222:9001";
      geo-ip = true;
    };
  };

}
