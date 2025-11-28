{
  ...
}:
{
  paul = {
    common-desktop.enable = true;
    dual-boot.enable = true;
    gnome.enable = true;
    nvidia.enable = true;
    grub.enable = true;
    gaming.enable = true;
    tailscale.enable = true;
    tor-client.enable = true;
    qmk.enable = true;
    jovian.enable = true;
    home-manager.profile = "gaming";
  };

  clan.core.deployment.requireExplicitUpdate = true;

  networking.networkmanager.enable = true;
}
