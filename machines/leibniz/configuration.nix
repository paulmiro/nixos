{
  betternix,
  pkgs,
  ...
}:
{
  imports = [
    betternix.nixosModules.default
  ];

  paul = {
    common-desktop.enable = true;
    gnome.enable = true;
    tor-client.enable = true;
    qmk.enable = true;
    tailscale.enable = true;
    systemd-boot.enable = true;

    home-manager.profile = "work-desktop";
  };

  betternix = {
    hosts.enable = true;
    postgresql.enable = true;
    rabbitmq.enable = true;
    trusted-certificates.enable = true;
  };

  clan.core.networking.targetHost = "leibniz";
  clan.core.deployment.requireExplicitUpdate = true;

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
