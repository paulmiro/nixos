{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.paul.sonarr;
in
{

  options.paul.sonarr = {
    enable = lib.mkEnableOption "activate sonarr";
    openFirewall = lib.mkEnableOption "allow sonarr port in firewall";
  };

  config = lib.mkIf cfg.enable {
    paul.group.arr.enable = true;
    paul.prowlarr.enable = true;
    paul.nfs-mounts.enableArr = true;

    ids.uids.sonarr = lib.mkForce 8989;

    users.users.sonarr.isSystemUser = true; # this should be set in the services.sonarr module, bit it isn't

    services.sonarr = {
      enable = true;
      user = "sonarr";
      group = "arr";
      openFirewall = cfg.openFirewall;
    };

    #TODO: remove this once Sonarr supports .NET 8 (https://github.com/Sonarr/Sonarr/issues/7442)
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-wrapped-6.0.36"
      "aspnetcore-runtime-6.0.36"
      "dotnet-sdk-wrapped-6.0.428"
      "dotnet-sdk-6.0.428"
    ];
  };
}
