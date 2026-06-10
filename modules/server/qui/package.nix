{
  age,
  gnutar,
  qui,
  stdenvNoCC,
  qui_theme_age_key,
  ...
}:
qui.overrideAttrs (old: {
  src = stdenvNoCC.mkDerivation rec {
    src = old.src;
    name = src.name;
    nativeBuildInputs = [
      age
      gnutar
    ];
    buildPhase = ":";
    installPhase = ''
      cp -r $src $out
      chmod -R 755 $out
      mkdir -p $out/web/src/themes/premium
      echo "${qui_theme_age_key}" | age --decrypt -i - -o premium.tar.gz "${./premium_themes.tar.gz.age}"
      tar -xzf premium.tar.gz -C "$out/web/src/themes/premium"
    '';
  };
})
