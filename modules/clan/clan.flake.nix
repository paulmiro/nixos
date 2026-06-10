{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    hasPrefix
    filterAttrs
    attrValues
    ;
in
{
  clan = {
    meta.name = "paulmiro-clan";

    # Make inputs and the flake itself accessible as module parameters.
    # Technically, adding the inputs is redundant as they can be also
    # accessed with self.inputs.X, but adding them individually
    # allows to only pass what is needed to each module.

    specialArgs = {
      inherit inputs;
      inherit (self) private versions;
    };

    inventory.instances = {
      importer-modules-dir = {
        module = {
          name = "importer";
          input = "clan-core";
        };
        roles.default.tags."all" = { };
        roles.default.extraModules = attrValues (
          # clan adds every machine as a module, so we need to filter here to prevent infinite recursion
          filterAttrs (n: _v: !hasPrefix "clan-machine-" n) self.nixosModules
        );
      };

      "borgbackup-turing" = {
        module = {
          name = "borgbackup";
          input = "clan-core";
        };
        roles.client.machines = {
          "backus" = { };
          "newton" = { };
        };

        roles.server.machines."turing".settings = {
          directory = "/mnt/borg";
        };
      };

      "borgbackup-backus" = {
        module = {
          name = "borgbackup";
          input = "clan-core";
        };
        roles.client.machines = {
          "turing" = { };
          "morse" = { };
        };

        roles.server.machines."backus".settings = {
          directory = "/mnt/borg";
        };
      };
    };
  };
}
