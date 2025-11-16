{
  writers,
  ...
}:
writers.writeRubyBin "nato" { } (builtins.readFile ./nato.rb)
