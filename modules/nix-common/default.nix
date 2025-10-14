{
  config,
  flake-self,
  lib,
  nixpkgs,
  pkgs,
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

    nixpkgs = {
      overlays = [ flake-self.overlays.paulmiro-overlay ];
      # Allow unfree licenced packages
      config.allowUnfree = true;
    };

    nix = {
      package = pkgs.nixVersions.stable;
      nixPath = [ "nixpkgs=${nixpkgs}" ];
      registry.nixpkgs.flake = nixpkgs;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-public-keys = lib.mkIf (cfg.disable-cache != true) [
          "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g=" # lounge.rocks
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="
        ];

        substituters = lib.mkIf (cfg.disable-cache != true) [
          "https://cache.lounge.rocks/nix-cache?priority=20"
          # chache.nixos.org has priority=40
          "https://cache.clan.lol/?priority=60"
          "https://nix-community.cachix.org/?priority=70"
        ];

        connect-timeout = 5;

        builders-use-substitutes = true;

        fallback = true;

        trusted-users = [
          "root"
          "@wheel"
        ];

        log-lines = 25;

        # Save space by hardlinking store files
        auto-optimise-store = true;

        min-free = (512 * 1024 * 1024);
        max-free = (2048 * 1024 * 1024);
      };

      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      daemonCPUSchedPolicy = if config.paul.common-desktop.enable then "idle" else "batch";
      daemonIOSchedClass = lib.mkDefault "idle";
      daemonIOSchedPriority = lib.mkDefault 7;
    };

    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };
  };
}
