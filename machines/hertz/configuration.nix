{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-server.enable = true;
    # systemd-boot.enable = true;
  };

  /*
    imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ];
  */

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "hertz";
    tempAddresses = "disabled";
    firewall = {
      allowedTCPPorts = [
        80 # http
        443 # https
      ];
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--accept-dns=false" "--advertise-exit-node" ];
  };

  environment.systemPackages = with pkgs; [ ];

}
