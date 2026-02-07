{
  lib,
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

  specialisation.desktop.configuration = {
    paul.jovian.enable = lib.mkForce false;
  };

  clan.core.deployment.requireExplicitUpdate = true;
}
