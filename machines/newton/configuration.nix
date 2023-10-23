# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, ... }:
{ config, pkgs, flake-self, ... }:

{

  paul = {
    user = {
      paulmiro.enable = true;
      root.enable = true;
    };
    gnome.enable = true;
    locale.enable = true;
    nix-common.enable = true;
    openssh.enable = true;
    sound.enable = true;
  };

  # programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";

  home-manager = {
    # DON'T set useGlobalPackages! It's not necessary in newer
    # home-manager versions and does not work with configs using
    # nixpkgs.config`
    useUserPackages = true;
    extraSpecialArgs = {
      # Pass all flake inputs to home-manager modules aswell so we can use them
      # there.
      inherit flake-self;
      # Pass system configuration (top-level "config") to home-manager modules,
      # so we can access it's values for conditional statements
      system-config = config;
    };
    users.paulmiro = flake-self.homeConfigurations.newton;
  };

  programs.zsh.enable = true;

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nvidia.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    networkmanager.enable = true;
    hostName = "newton";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "";
    xkbOptions = "caps:none";
  };

  # Configure console keymap
  console.keyMap = "de";

  services.tailscale = {
    enable = true; #TODO: tailscale up needs to be run manually once to log in
    useRoutingFeatures = "client";
    extraUpFlags = [ "--accept-routes" ];
  };
  # services.fprintd.enable = true; # does not work yet, no driver available for samsung
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  programs.steam.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?

}
