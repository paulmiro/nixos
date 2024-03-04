# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs, ... }:

{

  paul = {
    common-desktop.enable = true;
    gnome.enable = true;
    nvidia = { enable = true; laptop = true; };
    systemd-boot.enable = true;
    syncthing.enable = true;
  };

  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    networkmanager.enable = true;
    hostName = "newton";
  };

  programs.steam.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:none";
  };

  # Configure console keymap
  console.keyMap = "de";

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tailscale = {
    enable = true; #TODO: tailscale up needs to be run manually once to log in
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" "--operator=paulmiro" ];
  };
  # services.fprintd.enable = true; # does not work yet, no driver available for samsung
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ ];

}
