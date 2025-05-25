{ self, ... }:
{
  pkgs,
  lib,
  config,
  modulesPath,
  flake-self,
  home-manager,
  nixos-hardware,
  nixpkgs,
  ...
}:
let
  private = config.paul.private;
in
{

  paul = {
    common-server.enable = true;
  };

  imports = [
    # being able to build the sd-image
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"

    # https://github.com/NixOS/nixos-hardware/tree/master/raspberry-pi/3
    nixos-hardware.nixosModules.raspberry-pi-3
  ];

  # nix build .\#nixosConfigurations.pi3a.config.system.build.sdImage
  # add boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; to your x86 system
  # to build ARM stuff through qemu
  sdImage.compressImage = false;
  sdImage.imageBaseName = "raspi-image";

  networking = {
    hostName = "pi3a";
    networkmanager.enable = false;
    wireless.enable = true;
    wireless.networks = {
      "${private.networks.gndv.ssid}".psk = private.networks.gndv.psk;
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
