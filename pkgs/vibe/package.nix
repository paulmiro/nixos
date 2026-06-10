# nix run .\#woodpecker-pipeline
{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "vibe" ''
  trap 'kill $(jobs -p)' EXIT # kill the ollama server after the script has exited
  ${pkgs.ollama}/bin/ollama serve 2> /dev/null > /dev/null & # run the ollama server in the background
  sleep 1
  ${pkgs.ollama}/bin/ollama run codegemma "write a python script that does the following:

  $1\

  follow these rules:
  - only import python's built-in modules, and only do so if neccessary
  - write fast, efficient code without compromizing correctness
  - do not read files unless you are told to do so
  - never try to read from stdin or expect user input, instead expect command line arguments when input is needed
  - only give me the code and no explaination
  " | ${pkgs.perl}/bin/perl -0777 -ne 'print "$1" if /```python(.*?)```/s' | ${pkgs.python3}/bin/python - ''${@:2}
''
