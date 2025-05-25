{ lib, config, ... }:
with lib;
let
  cfg = config.paul.syncthing;
in
{

  options.paul.syncthing = {
    enable = mkEnableOption "Enable Syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "paulmiro";
      dataDir = "/home/paulmiro/.local/share/syncthing";
      configDir = "/home/paulmiro/.config/syncthing";
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      openDefaultPorts = true;
      settings = {

        devices = {
          "bell" = {
            id = "A7SHOWS-TWZ44IH-IHTFLKW-S6VXXYM-G5PVEHJ-RSMBZIB-O5AFW6B-3QCFHQL";
          };
          "newton" = {
            id = "GO53PCT-CGJPNMT-NWTGQ5D-REHZFXK-V4P4FRA-EUCLMA7-GB33L5T-ESJLDAQ";
          };
        };
        folders = {
          "Obsidian" = {
            # Name of folder in Syncthing, also the folder ID
            path = "/home/paulmiro/Documents/Obsidian"; # Which folder to add to Syncthing
            id = "tqjey-7qgnz";
            devices = [ "bell" ]; # Which devices to share the folder with
          };
        };
      };
    };
  };
}
