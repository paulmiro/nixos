{
  lib,
  nixos-avf,
  ...
}:
{
  imports = [
    nixos-avf.nixosModules.avf
  ];

  paul.common.enable = true;

  avf.defaultUser = "paulmiro";

  # prevent error mesaages when offline
  clan.core.deployment.requireExplicitUpdate = true;

  clan.core.networking.targetHost = "bell-avf";

  networking.hostName = "bell-avf";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
