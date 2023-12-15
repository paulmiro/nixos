{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;

    nginx.enable = true;

    librespeedtest = {
      enable = true;
      enableNginx = true;
    };
    jellyfin = {
      enable = true;
      enableNginx = true;
    };
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
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
    networkmanager.enable = true;
    hostName = "hawking";
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
    extraUpFlags = [ "--accept-dns=false" ];
  };

  # Running fstrim weekly is a good idea for VMs.
  # Empty blocks are returned to the host, which can then be used for other VMs.
  # It also reduces the size of the qcow2 image, which is good for backups.
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };


  fileSystems."/mnt/nfs/data" = {
    device = "turing:/mnt/TANK1/data";
    fsType = "nfs";
  };
  fileSystems."/mnt/nfs/playground" = {
    device = "turing:/mnt/TANK1/playground";
    fsType = "nfs";
  };


  environment.systemPackages = with pkgs; [ ];

}
