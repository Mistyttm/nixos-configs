{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "amethyst-theme";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "themes";
      owner = "dgudim";
      rev = "0852449e1a5052d8b2689240a0914834fdda306c";
      hash = "";
    };  
    installPhase = ''
      mkdir -p $out/share/plasma/look-and-feel
      cp -aR KDE-loginscreens/Illusion/* $out/share/plasma/look-and-feel/Illusion  
    '';
  }
