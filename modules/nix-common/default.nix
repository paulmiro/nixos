{
  config,
  pkgs,
  lib,
  flake-self,
  nixpkgs,
  ...
}:
let
  cfg = config.paul.nix-common;
in
{

  options.paul.nix-common = {
    enable = lib.mkEnableOption "activate nix-common";
    disable-cache = lib.mkEnableOption "not use binary-cache";
  };

  config = lib.mkIf cfg.enable {

    # Set the $NIX_PATH entry for nixpkgs. This is necessary in
    # this setup with flakes, otherwise commands like `nix-shell
    # -p pkgs.htop` will keep using an old version of nixpkgs.
    # With this entry in $NIX_PATH it is possible (and
    # recommended) to remove the `nixos` channel for both users
    # and root e.g. `nix-channel --remove nixos`. `nix-channel
    # --list` should be empty for all users afterwards
    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

    # allow the use of `nix run nixpkgs#hello` instead of nix run 'github:nixos/nixpkgs#hello'
    nix.registry.nixpkgs.flake = nixpkgs;

    nixpkgs = {
      overlays = [ ];
      # Allow unfree licenced packages
      config.allowUnfree = true;
    };

    nix = {

      package = pkgs.nixVersions.stable;
      extraOptions = ''
        # this enables the technically experimental feature Flakes
        experimental-features = nix-command flakes

        # If set to true, Nix will fall back to building from source if a binary substitute fails.
        fallback = true

        # the timeout (in seconds) for establishing connections in the binary cache substituter. 
        connect-timeout = 10

        # these log lines are only shown on a failed build
        log-lines = 25

        # Free up to 1GiB whenever there is less than 100MiB left.
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      settings = {
        trusted-public-keys = lib.mkIf (cfg.disable-cache != true) [
          "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g="
        ];
        substituters = lib.mkIf (cfg.disable-cache != true) [
          "https://cache.lounge.rocks/nix-cache"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];

        # Users allowed to run nix
        allowed-users = [ "root" ];

        # Save space by hardlinking store files
        auto-optimise-store = true;
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

    };

  };
}
