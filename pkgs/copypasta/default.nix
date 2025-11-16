# idea from
# https://codeberg.org/EvanHahn/dotfiles/src/branch/main/home/bin/bin/copy
# https://codeberg.org/EvanHahn/dotfiles/src/branch/main/home/bin/bin/pasta
# but rewritten for my needs
{
  runCommand,
  wl-clipboard,
  writeShellScript,
  xclip,
  ...
}:
let
  cacheDir = ''"''${XDG_CACHE_HOME:-$HOME/.cache}/copypasta"'';
  copy = writeShellScript "copy" ''
    set -euo pipefail

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      ${wl-clipboard}/bin/wl-copy $@
    elif [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$XDG_SESSION_TYPE" = "xorg" ]; then
      if [ -z $1 ]; then
        ${xclip}/bin/xclip -selection clipboard
      else
        echo "$@" | ${xclip}/bin/xclip -selection clipboard
      fi
    else
      mkdir -p ${cacheDir}
      if [ -z $1 ]; then
        cat > ${cacheDir}/clipboard
      else
        echo "$@" > ${cacheDir}/clipboard
      fi
      chmod 600 ${cacheDir}/clipboard
    fi
  '';
  pasta = writeShellScript "pasta" ''
    set -euo pipefail

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      ${wl-clipboard}/bin/wl-paste
    elif [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$XDG_SESSION_TYPE" = "xorg" ]; then
      ${xclip}/bin/xclip -selection clipboard -o
    elif [[ -e ${cacheDir}/clipboard ]]; then
      cat ${cacheDir}/clipboard
    else
      echo
    fi
  '';
in
runCommand "copypasta" { } ''
  mkdir -p $out/bin
  ln -s ${copy} $out/bin/copy
  ln -s ${pasta} $out/bin/pasta
''
