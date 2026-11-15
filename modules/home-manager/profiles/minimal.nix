# This file gets imported for ALL home-manager profiles
{
  lib,
  ...
}:
{
  config = {
    paul = {
      claude.enable = lib.mkForce false;
    };
  };
}
