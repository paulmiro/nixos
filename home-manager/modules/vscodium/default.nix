{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.vscodium;
in
{
  options.paul.programs.vscodium.enable = mkEnableOption "enable vscodium";

  config = mkIf cfg.enable {

    # Enable Wayland support, disabeled for now because it breaks obsidian (and maybe other electron apps)
    # home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      # enableExtensionUpdateCheck = false;
      # enableUpdateCheck = false;

      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.vscode.keybindings
      # keybindings = [ ];

      # ~/.config/Code/User/settings.json
      # userSettings = {
      #   # privacy
      #   "telemetry.telemetryLevel" = "off";

      #   # style
      #   "terminal.integrated.fontFamily" = "source code pro";
      #   "workbench.colorTheme" = "GitHub Dark Default";

      #   # jnoortheen.nix-ide
      #   "nix" = {
      #     "enableLanguageServer" = true;
      #     "serverPath" = "${pkgs.nil}/bin/nil";
      #     "serverSettings" = {
      #       "nil" = {
      #         "formatting" = {
      #           "command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
      #         };
      #       };
      #     };
      #   };
      # };

      # extensions = with pkgs.vscode-extensions; [
      #   github.copilot
      #   github.github-vscode-theme
      #   github.vscode-github-actions
      #   github.vscode-pull-request-github
      #   james-yu.latex-workshop
      #   jnoortheen.nix-ide
      #   ms-python.python
      #   ms-vscode-remote.remote-ssh
      #   redhat.vscode-xml
      #   redhat.vscode-yaml
      #   yzhang.markdown-all-in-one
      # ];

    };
  };
}
