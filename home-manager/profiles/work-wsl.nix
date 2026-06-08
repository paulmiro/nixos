{ self, ... }:
{
  flake.homeProfiles.work-wsl =
    {
      ...
    }:
    {
      imports = [
        self.homeProfiles.common
      ];

      config = {
        paul = {
          work.enable = true;
        };
      };
    };
}
