{
  ...
}:
{
  paul = {
    common-desktop.enable = true;
    gnome.enable = true;
    nvidia.enable = true;
    grub.enable = true;
    gaming.enable = true;
    tailscale.enable = true;
    tor-client.enable = true;
    qmk.enable = true;
  };

  clan.core.deployment.requireExplicitUpdate = true;

  networking.networkmanager.enable = true;
}
