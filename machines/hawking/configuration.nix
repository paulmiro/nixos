{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
    docker.enable = true;
    nginx.enable = true;

    librespeedtest = {
      enable = true;
      enableNginx = true;
    };
    jellyfin = {
      enable = true;
      enableNginx = true;
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

  environment.systemPackages = with pkgs; [ ];

}
