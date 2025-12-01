{
  writeShellScriptBin,
  ...
}:
writeShellScriptBin "mkscript" ''
  set -euo pipefail

  if [[ $# == 1 ]]; then
    name=$1
  else
    read -r -p "Script name: " name
  fi

  dir=pkgs/$name
  file=$dir/default.nix

  if mkdir $dir; then true; else
    echo "Package $name already exists, aborting."
    exit 1
  fi

  touch $file
  cat > $file <<EOF
  {
    writeShellScriptBin,
    ...
  }:
  writeShellScriptBin "$name" '''
    set -euo pipefail
    
  '''
  EOF

  if [[ -z ''${EDITOR:-} ]]; then
    exit 0
  fi

  echo "Opening file with $EDITOR..."

  if [[ "$EDITOR" == 'code' ]]; then
    code --goto $file:7:2
  else
    $EDITOR $file
  fi
''
