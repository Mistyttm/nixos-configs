{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "amethyst-theme";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "Amethyst";
      owner = "ddh4r4m";
      rev = "a6af9b7727e0337b98a5705bc60b9a6b841761c7";
      hash = "sha256-8F5CF+yzViyDUJuKDdbAP1KCgZx7HOqtJGWbxztBokk=";
    };  
    installPhase = ''
      mkdir -p $out/share/plasma/look-and-feel
      mkdir -p $out/share/plasma/desktoptheme
      cp -aR plasma/* $out/share/plasma
    '';
  }
