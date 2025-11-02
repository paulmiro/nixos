{
  lib,
  ...
}:
{
  options.paul.ci = {
    enable = lib.mkEnableOption "include this machine in ci runs" // {
      default = true;
    };
  };
}
