{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "plasma6-window-title-applet";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "plasma6-window-title-applet";
      owner = "dhruv8sh";
      rev = "a6eaf5086a473919ed2fffc5d3b8d98237c2dd41";
      hash = "";
    };
    installPhase = ''
      echo "Installing window-title-applet"
      mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
      cp -aR * $out/share/plasma/plasmoids/org.kde.windowtitle
    '';
  }
