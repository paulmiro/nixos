{
  config,
  direnv-instant,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.direnv;
  direnv-instant-package = direnv-instant.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.paul.programs.direnv = {
    enable = lib.mkEnableOption "activate direnv";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = false; # replaced by direnv-instant
        nix-direnv.enable = true;
        config = {
          global = {
            hide_env_diff = true;
          };
        };
      };

      zsh.initContent = ''
        eval "$(${direnv-instant-package}/bin/direnv-instant hook zsh)"

        nixify() {
          if [ ! -e ./.envrc ]; then
            echo "use nix" > .envrc
            direnv allow
          fi
          if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
            cat > default.nix <<'EOF'
        with import <nixpkgs> {};
        mkShell {
          nativeBuildInputs = [
            bashInteractive
          ];
        }
        EOF
            ''${"EDITOR:-nano"} default.nix
          fi
        }

        flakify() {
          if [ ! -e flake.nix ]; then
            nix flake new -t github:nix-community/nix-direnv .
          elif [ ! -e .envrc ]; then
            echo "use flake" > .envrc
            direnv allow
          fi
          ''${"EDITOR:-nano"} flake.nix
        }
      '';

      # vscode = {
      #   extensions = with pkgs.vscode-extensions; [ mkhl.direnv ];
      # };

    };

    home.packages = [
      direnv-instant-package
    ];

    xdg.configFile."direnv/direnvrc".text = ''
      # Set cache dir
      : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
      declare -A direnv_layout_dirs
      direnv_layout_dir() {
          local hash path
          echo "''${direnv_layout_dirs[$PWD]:=$(
              hash="$(sha1sum - <<< "$PWD" | head -c40)"
              path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
          )}"
      }
    '';

  };
}
