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
}
