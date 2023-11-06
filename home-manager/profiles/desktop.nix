{ pkgs, lib, config, ... }:
with lib;
{
  config = {

    paul = {
      programs.vscode.enable = true;
    };

    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      git = { ignores = [ ".direnv/" ]; };
    };

    # Install these packages for my user
    home.packages = with pkgs; [
      bun
      clang
      discord
      firefox
      go
      gparted
      jellyfin-mpv-shim
      libreoffice
      lua
      mpv
      nvtop
      obsidian
      protonmail-bridge
      prusa-slicer
      ripgrep
      signal-desktop
      stylua
      thunderbird-bin
      xournalpp
      zoom-us

      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.gesture-improvements
      gnomeExtensions.just-perfection

      # example for a function building python with some packages
      (python3.withPackages (ps: with ps; [
        requests
        numpy
        jupyter
      ]))
    ];

  };
}
