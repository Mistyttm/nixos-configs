{ pkgs }: 
  pkgs.stdenv.mkDerivation {
    pname = "tela-circle-icons";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "Tela-icon-theme";
      owner = "vinceliuice";
      rev = "80b86a4a57ab243ec16c5c27b920f3544706955d";
      hash = "sha256-T5/VnQgSaJF/WnYWxwI1DCtj2u0Ncoz++LGGcPj8xH8=";
    };  
    installPhase = ''
       # Create the destination directory
        mkdir -p $out/share/icons

        # Define color and theme name
        color="purple"
        THEME_NAME="Tela-circle-$color"

        # Create the theme directory
        THEME_DIR="$out/share/icons/$THEME_NAME"
        mkdir -p "$THEME_DIR"

        # Copy the source files
        cp -r src/* "$THEME_DIR"
        cp -r links/* "$THEME_DIR"

        # Update index.theme
        sed -i "s/%NAME%/$THEME_NAME/g" "$THEME_DIR/index.theme"

        # Apply color customization
        find "$THEME_DIR" -type f -name "*.svg" -exec sed -i \
          -e "s/#5294e2/#7e57c2/g" \
          -e "/\ColorScheme-Highlight/s/currentColor/#7e57c2/" \
          -e "/\ColorScheme-Background/s/currentColor/#ffffff/" {} +

        # Create symlinks for HiDPI
        ln -sr "$THEME_DIR/16" "$THEME_DIR/16@2x"
        ln -sr "$THEME_DIR/22" "$THEME_DIR/22@2x"
        ln -sr "$THEME_DIR/24" "$THEME_DIR/24@2x"
        ln -sr "$THEME_DIR/32" "$THEME_DIR/32@2x"
        ln -sr "$THEME_DIR/scalable" "$THEME_DIR/scalable@2x"
    '';
  }
