{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.tailscale;
  hasAny = cfg.services != { };
in
{
  options.paul.tailscale = {
    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
            };
            port = lib.mkOption {
              type = lib.types.port;
            };
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "tailscale-serve-${name}" {
        description = "Tailscale service for ${name}";
        after = [
          "tailscaled.service"
        ];
        serviceConfig = {
          Type = "forking";
          RemainAfterExit = "true";
          ExecStart = "${pkgs.tailscale}/bin/tailscale serve --service=svc:${name} --https=443 ${value.host}:${toString value.port}";
          ExecStop = "${pkgs.tailscale}/bin/tailscale serve clear svc:${name}";
          Restart = "on-failure";
        };
      }
    ) cfg.services;

    networking.firewall.interfaces = lib.mkIf hasAny {
      "tailscale".allowedTCPPorts = [ 443 ];
    };
  };
}
