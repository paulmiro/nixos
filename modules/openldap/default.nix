{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.openldap;
in
{

  # TODO: anonymous bind aus machen, das ist sonst eine viel zu große lücke

  #########################################################################
  # WARNING: This module is NOT enterely stateless
  # The following setup is needed:
  # 1. place setup.ldif on the host machine
  # 2. run ldapadd -x -D "cn=ldapadmin,dc=kiste,dc=dev" -W -f setup.ldif
  #
  # This could potentially be avoided by automating this somehow, but I
  # don't know how to do that 🤷
  #########################################################################

  options.paul.openldap = {

    enable = mkEnableOption "activate openldap";

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/openldap/data";
      description = "The directory where the LDAP data is stored";
    };

    rootDN = mkOption {
      type = types.str;
      default = "dc=kiste,dc=dev";
      description = "The root DN for the LDAP server";
    };

    adminPasswordFile = mkOption {
      type = types.str;
      default = "/run/keys/openldap-admin-password";
      description = "The file where the admin password is stored";
    };

  };

  config = mkIf cfg.enable {

    services.openldap = {
      enable = true;
      user = "openldap";
      /* enable plain connections only */
      urlList = [ "ldap:///" ];


      settings = {
        attrs = {
          olcLogLevel = "conns config";
        };

        children = {
          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          ];

          "olcDatabase={1}mdb" = {
            attrs = {
              objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];

              olcDatabase = "{1}mdb";
              olcDbDirectory = cfg.dataDir;

              olcSuffix = cfg.rootDN;

              /* your admin account, do not use writeText on a production system */
              olcRootDN = "cn=ldapadmin,${cfg.rootDN}";
              #TODO: for some reason using olcRootPW.path does not work, that's why it's hardcoded for now
              olcRootPW = builtins.readFile ../../secrets/openldap-admin-password-hashed;

              olcAccess = [
                /* custom access rules for userPassword attributes */
                ''{0}to attrs=userPassword
                  by self write
                  by anonymous auth
                  by * none''

                /* allow read on anything else */
                ''{1}to *
                  by * read''
              ];
            };

            children = {
              "olcOverlay={2}ppolicy".attrs = {
                objectClass = [ "olcOverlayConfig" "olcPPolicyConfig" "top" ];
                olcOverlay = "{2}ppolicy";
                olcPPolicyHashCleartext = "TRUE";
              };

              "olcOverlay={3}memberof".attrs = {
                objectClass = [ "olcOverlayConfig" "olcMemberOf" "top" ];
                olcOverlay = "{3}memberof";
                olcMemberOfRefInt = "TRUE";
                olcMemberOfDangling = "ignore";
                olcMemberOfGroupOC = "groupOfNames";
                olcMemberOfMemberAD = "member";
                olcMemberOfMemberOfAD = "memberOf";
              };

              "olcOverlay={4}refint".attrs = {
                objectClass = [ "olcOverlayConfig" "olcRefintConfig" "top" ];
                olcOverlay = "{4}refint";
                olcRefintAttribute = "memberof member manager owner";
              };
            };
          };
        };
      };

    };

    ## TODO: this does not work becuase of the issue mentioned above
    /*
      # this breaks on first deploy, because the user does not exist yet
      # to fix this, three steps are needed:
      # 1. delploy only the user config
      # 2. deploy only the secret (perhaps by activating this module entirely and using {hostname}:deploy-secrets)
      # 3. deploy the full config

      lollypops.secrets.files."openldap-admin-password" = {
      cmd = "rbw get keycloak --field=openldap-admin-password";
      path = cfg.adminPasswordFile;
      owner = "openldap";
      };

      users.users.openldap = {
      isSystemUser = true;
      home = cfg.dataDir;
      group = "openldap";
      extraGroups = [ "keys" ]; #for access to /run/keys
      };

      users.groups.openldap = { };
    */
  };

}
