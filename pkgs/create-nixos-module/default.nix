{
  writeShellScriptBin,
  ...
}:
writeShellScriptBin "mkmod" ''
  set -euo pipefail

  if [[ $# == 1 ]]; then
    name=$1
  else
    read -r -p "Module name: " name
  fi

  dir=modules/$name
  file=$dir/default.nix

  if mkdir $dir; then true; else
    echo "Nixos Module $name already exists, aborting."
    exit 1
  fi

  touch $file
  cat > $file <<EOF
  {
    config,
    lib,
    pkgs,
    ...
  }:
  let
    cfg = config.paul.$name;
  in
  {
    options.paul.$name = {
      enable = lib.mkEnableOption "enable $name";
    };

    config = lib.mkIf cfg.enable {
      
    };
  }
  EOF

  if [[ -z ''${EDITOR:-} ]]; then
    exit 0
  fi

  echo "Opening file with $EDITOR..."

  if [[ "$EDITOR" == 'code' ]]; then
    code --goto "$file":16:4
  else
    $EDITOR $file
  fi
''
