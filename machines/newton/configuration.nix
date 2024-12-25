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
    grub.enable = true;
    syncthing.enable = true;
    adb.enable = true;
    docker.enable = true;
    gaming.enable = true;
  };

  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
    hostName = "newton";
  };


  services.openvpn.servers = {
    infoBonnVPN = {
      config = '' config /home/paulmiro/Downloads/openvpn/uni-info.ovpn '';
      autoStart = false;
    };
  };

  # disable NetworkManager wait-online
  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = pkgs.lib.mkForce false;
  systemd.services.systemd-networkd-wait-online.enable = pkgs.lib.mkForce false;

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
  boot.supportedFilesystems = [ "ntfs" ];

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
  environment.systemPackages = with pkgs; [
    vial
  ];
  services.udev.packages = with pkgs; [
    vial
    qmk-udev-rules
  ];

  hardware.keyboard.qmk.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
