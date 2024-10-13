{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "dracula-cursors";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "gtk";
      owner = "dracula";
      rev = "e5c95d75f4e04b91d9f47ff5395fcf0376cc045d";
      hash = "";
    };
    buildInputs = [ pkgs.inkscape pkgs.xorg.xcursorgen ];
    buildPhase = ''
      build.sh
    '';
    installPhase = ''
      mkdir -p $out/share/icons/Dracula-cursors
      cp -r Dracula-cursors/* $out/share/icons/Dracula-cursors
    '';
  }