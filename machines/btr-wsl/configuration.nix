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

  paul = {
    common.enable = true;
    home-manager.profile = "work-wsl";
    kanidm.enableClient = true;
    docker.enable = true;
    tor-client.enable = true;
  };

  # prevent error messages when offline
  clan.core.deployment.requireExplicitUpdate = true;
  clan.core.enableRecommendedDefaults = false; # this breaks networking
  clan.core.networking.targetHost = "btr-wsl";

  programs.nix-ld.enable = true; # to allow VSCode-server to run

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
