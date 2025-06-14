{
  lib,
  ...
}:
{
  options.paul.clan = {
    # this exists so that the first rebuild into this flake on a new machine can be done normally
    # modules that are enabled by any of the common modules and depend on clan-specifig config
    # should use this value to fall back to something that doesn't need clan
    enable = lib.mkOption {
      description = "enable clan-specific configuration (mainly secrets)";
      type = lib.types.str;
      default = true;
    };
  };
}
