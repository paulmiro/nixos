{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.kanidm;
  domain = config.paul.private.domains.kanidm; # not set as an option because it should never be changed
in
{
  options.paul.kanidm = {
    enable = lib.mkEnableOption "enable kanidm server";
    enableClient = lib.mkEnableOption "enable kanidm client";
    disableLdaps = lib.mkEnableOption "disable ldaps in kandim";
    openHttpsFirewall = lib.mkEnableOption "open kanidm https port in the firewall";
    openLdapsFirewall = lib.mkEnableOption "open kanidm ldaps port in the firewall";

    httpsPort = lib.mkOption {
      description = "internal https port for kanidm";
      type = lib.types.port;
      default = 8443; # pretty much arbitrary
    };

    ldapsPort = lib.mkOption {
      description = "ldaps port for kanidm";
      type = lib.types.port;
      default = 3636; # TODO: change to 636 once authentik is turned off (most tooling expects port 636 for ldaps)
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.kanidm = {
        enableServer = true;

        package = pkgs.kanidm_1_7;

        serverSettings = {
          version = "2";
          origin = "https://${domain}";
          domain = domain;
          # we usually want to bind to ::1, but opening the firewall is pointless without binding to an accessible ip
          bindaddress = "[::${lib.mkIf (!cfg.openHttpsFirewall) "1"}]:${toString cfg.httpsPort}";
          ldapbindaddress =
            lib.mkIf (!cfg.disableLdaps)
              "[::${lib.mkIf (!cfg.openLdapsFirewall) "1"}]:${toString cfg.ldapsPort}";
          http_client_address_info.x-forward-for = [ "::1" ];
          tls_chain = "/var/lib/kanidm/cert.pem";
          tls_key = "/var/lib/kanidm/key.pem";
        };
      };

      services.nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        enableDyndns = true;
        locations."/" = {
          proxyPass = "https://${domain}";
        };
      };

      security.acme.certs.${domain} = {
        postRun = ''
          cp -Lv {cert,key,chain}.pem /var/lib/kanidm
          chown kanidm:kanidm /var/lib/kanidm/{cert,key,chain}.pem
          chmod 400 /var/lib/kanidm/{cert,key,chain}.pem
        '';
        reloadServices = [ "kanidm.service" ];
      };

      networking.firewall.allowedTCPPorts = [
        (lib.mkIf cfg.openHttpsFirewall cfg.httpsPort)
        (lib.mkIf cfg.openLdapsFirewall cfg.ldapsPort)
      ];
    })

    (lib.mkIf cfg.enableClient {
      services.kanidm = {
        enableClient = true;

        clientSettings = {
          uri = "https://${domain}";
        };
      };
    })
  ];
}
