{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.qui-with-premium-themes = pkgs.qui.overrideAttrs (old: {
        src = pkgs.stdenvNoCC.mkDerivation {
          src = old.src;
          name = old.src.name;
          nativeBuildInputs = [
            pkgs.age
            pkgs.gnutar
          ];
          dontBuild = true;
          installPhase = ''
            cp -r $src $out
            chmod -R 755 $out
            mkdir -p $out/web/src/themes/premium
            echo "${self.private.misc.qui_theme_age_key}" | age --decrypt -i - -o premium.tar.gz "${./premium_themes.tar.gz.age}"
            tar -xzf premium.tar.gz -C "$out/web/src/themes/premium"
          '';
        };
      });
    };
}
