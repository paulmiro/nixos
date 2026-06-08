{ self, ... }:
{
  flake.homeProfiles.server =
    {
      ...
    }:
    {
      imports = [
        self.homeProfiles.common
      ];

      config = {
      };
    };
}
