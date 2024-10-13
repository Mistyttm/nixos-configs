{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "illusion-splash-screen";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "themes";
      owner = "dgudim";
      rev = "0852449e1a5052d8b2689240a0914834fdda306c";
      hash = "sha256-B//TSYf9WUgfo6N6CJe6ffCNNBLrzeY/RaPZbUsIS+8=";
    };  
    installPhase = ''
      ls
      mkdir -p $out/share/plasma/look-and-feel
      cp -aR KDE-loginscreens/Illusion/* $out/share/plasma/look-and-feel/Illusion  
    '';
  }
