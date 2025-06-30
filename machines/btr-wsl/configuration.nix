{
  lib,
  nixos-wsl,
  ...
}:

{
  # NixOS-WSL specific options are documented on the NixOS-WSL repository:
  # https://github.com/nix-community/NixOS-WSL

  imports = [
    nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = "paulmiro";
    #interop.includePath = false;
  };

  # prevent error messages when offline
  clan.core.deployment.requireExplicitUpdate = true;
  clan.core.enableRecommendedDefaults = false; # this breaks networking
  clan.core.networking.targetHost = "btr-wsl";

  networking.hostName = "btr-wsl";

  paul.common.enable = true;

  programs.nix-ld.enable = true; # to allow VSCode-server to run

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
