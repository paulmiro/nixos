{
  pkgs,
  ...
}:
{
  paul = {
    common-desktop.enable = true;
    gnome.enable = true;
    nvidia = {
      enable = true;
      laptop = true;
    };
    grub.enable = true;
    syncthing.enable = true;
    adb.enable = true;
    docker.enable = true;
    gaming.enable = true;
    kanidm.enableClient = true;
    tor-client.enable = true;
    qmk.enable = true;
  };

  clan.core.networking.targetHost = "newton";

  clan.core.state.home = {
    folders = map (path: "/home/paulmiro/" + path) [
      "Documents"
      "Downloads"
      "Desktop"
      "Pictures"
      "Videos"
      "Music"
    ];
  };

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-routes"
      "--operator=paulmiro"
    ];
  };

  ### 39C3 ####

  networking.networkmanager.ensureProfiles.profiles = {
    "39C3" = {
      connection = {
        id = "39C3";
        type = "wifi";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "39C3";
      };
      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        anonymous-identity = "39C3";
        eap = "ttls;";
        identity = "39C3";
        password = "39C3";
        phase2-auth = "pap";
        altsubject-matches = "DNS:radius.c3noc.net";
        ca-cert = "${builtins.fetchurl {
          url = "https://letsencrypt.org/certs/isrgrootx1.pem";
          sha256 = "sha256:1la36n2f31j9s03v847ig6ny9lr875q3g7smnq33dcsmf2i5gd92";
        }}";
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "default";
        method = "auto";
      };
    };
  };
}
