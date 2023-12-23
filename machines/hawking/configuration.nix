{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;

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

    # Local Services
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
    homepage = {
      enable = true;
      openFirewall = true;
    };
    thelounge = {
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

}
