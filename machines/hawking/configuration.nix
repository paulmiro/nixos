{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-server.enable = true;
    systemd-boot.enable = true;
  };

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    networkmanager.enable = true;
    hostName = "hawking";
    firewall = {
      allowedTCPPorts = [ 8096 ];
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tailscale = {
    enable = true;
    enableRoutingFeatures = "server";
    extraUpFlags = [ "--accept-dns=false" ];
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ ];

}
