{ self, ... }:
{
  flake.nixosModules.clan =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.paul.clan;
    in
    {
      options.paul.clan = {
        # This exists so that the first rebuild into this flake on a new machine can be done normally.
        # Modules that are enabled by any of the common modules and depend on clan-specifig config
        # should use this value to fall back to something that doesn't need clan
        enable = lib.mkEnableOption "enable clan-specific configuration (mainly secrets)" // {
          default = true;
        };

        manageUserPasswords = lib.mkEnableOption "enable user passwords";

        buildHost = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "The hostname of the build host";
        };
      };

      config = lib.mkIf cfg.enable {
        paul.clan = {
          manageUserPasswords = lib.mkDefault true;
        };

        networking.hostName = lib.mkDefault config.clan.core.settings.machine.name;

        clan.core.networking.targetHost = lib.mkDefault "${config.networking.hostName}.${self.private.domains.tailnet}";
        clan.core.networking.buildHost = lib.mkIf (cfg.buildHost != null) (
          lib.mkDefault "paulmiro@${cfg.buildHost}.${self.private.domains.tailnet}"
        );
      };
    };
}
