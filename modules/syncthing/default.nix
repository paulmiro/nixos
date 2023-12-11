{ lib, config, ... }:
with lib;
let cfg = config.paul.syncthing;
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
          "bell" = { id = "GRB5ETA-WQY5EB4-54DIITE-DJYPQKK-JKZRFCP-JD3ARQQ-VYDUAD4-HBHUNAB"; };
          "faraday" = { id = "H4ZPPTO-AO6366E-XNMVDEH-TMUAV7A-C7CZCRX-532V3RG-XKFYRM4-3ZMLQAG"; };
          "hawking" = { id = "M45QIV6-CT5X7RT-BKCEBQ3-ONGC3CU-DLSD2NW-JLXOTNX-HOTRB5C-WIMXIAV"; }; # TODO: names here are old versions
          "baird" = { id = "X42F2D7-IYKC55X-JYLLSFO-MTP35ZD-SPBR22V-JLAXF7L-IMXBCMA-HFDHHQP"; };
        };
        folders = {
          "Obsidian" = {
            # Name of folder in Syncthing, also the folder ID
            path = "/home/paulmiro/Documents/Obsidian"; # Which folder to add to Syncthing
            id = "tqjey-7qgnz";
            devices = [ "bell" "faraday" "hawking" ]; # Which devices to share the folder with
          };
        };
      };
    };
  };
}
