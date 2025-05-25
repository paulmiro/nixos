{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.paul.unbound;
  dns-overwrites-config = builtins.toFile "dns-overwrites.conf" (
    ''
      # DNS overwrites
    ''
    + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: v: "local-data: \"${n} A ${toString v}\"") cfg.A-records
    )
  );
in
{

  options.paul.unbound = with lib; {
    enable = mkEnableOption "activate unbound";
    A-records = mkOption {
      type = types.attrs;
      default = {
        "iceportal.de" = "172.18.1.110";
        "pass.telekom.de" = "109.237.176.33";
      };
      description = ''
        Custom DNS A records
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    services.unbound = {
      enable = true;
      settings = {
        server = {
          include = [ "\"${dns-overwrites-config}\"" ];
          interface = [ "127.0.0.1" ];
          access-control = [ "127.0.0.0/8 allow" ];
        };
        forward-zone = [
          {
            name = "google.*.";
            forward-addr = [
              "8.8.8.8@853#dns.google"
              "8.8.8.4@853#dns.google"
            ];
            forward-tls-upstream = "yes";
          }
          {
            name = ".";
            forward-addr = [
              "1.1.1.1@853#cloudflare-dns.com"
              "1.0.0.1@853#cloudflare-dns.com"
            ];
            forward-tls-upstream = "yes";
          }
        ];
      };
    };

  };

}
