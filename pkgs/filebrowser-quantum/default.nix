{
  fetchurl,
  ffmpeg,
  runCommand,
  ...
}:
let
  file = fetchurl {
    url = "https://github.com/gtsteffaniak/filebrowser/releases/download/v1.0.1-stable/linux-amd64-filebrowser";
    hash = "sha256-yd9Y6dNhhg2qFVTF4GgLm8t3laNbhAT8wNrarOFJQ6g=";
    executable = true;
  };
in
runCommand "filebrowser-quantum" { } ''
  mkdir -p $out/bin
  ln -s ${file} $out/bin/filebrowser-quantum
''
