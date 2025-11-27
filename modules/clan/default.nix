{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.clan;
in
{
  imports = [
    ./state.nix
  ];

  options.paul.clan = {
    # This exists so that the first rebuild into this flake on a new machine can be done normally.
    # Modules that are enabled by any of the common modules and depend on clan-specifig config
    # should use this value to fall back to something that doesn't need clan
    enable = lib.mkEnableOption "enable clan-specific configuration (mainly secrets)" // {
      default = true;
    };

    manageUserPasswords = lib.mkEnableOption "enable user passwords";
  };

  config = lib.mkIf cfg.enable {
    paul.clan = {
      manageUserPasswords = lib.mkDefault true;
    };

    networking.hostName = lib.mkDefault config.clan.core.settings.machine.name;

    clan.core.settings.state-version.enable = lib.mkDefault true; # TODO: only here because of btr-wsl, is included in enableRecommendedDefaults

    clan.core.networking.targetHost = lib.mkDefault "${config.networking.hostName}.${config.paul.private.domains.tailnet}";
  };
}
