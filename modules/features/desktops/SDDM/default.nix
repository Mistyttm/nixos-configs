{...}: {
  flake.nixosModules.sddm = {pkgs, ...}: let
    # Written to theme.conf.user, overriding the theme's theme.conf.
    # Values below are the upstream defaults.
    sddmTheme = pkgs.sddm-eucalyptus-drop.override {
      themeConfig.General = {
        # Path relative to the theme root, or an absolute path (e.g. "${./wallpaper.jpg}")
        Background = "${./jellies.jpg}";
        # 0–1 alpha of a darkening overlay on the background
        DimBackgroundImage = "0.0";
        # Crop when scaling proportionally; false fits the whole image instead
        ScaleImageCropped = "true";

        ## Blur
        FullBlur = "false";
        # With HaveFormBackground, makes the form background translucent over the blur
        PartialBlur = "true";
        # Above 100 is strong and may slow rendering; 0 disables
        BlurRadius = "100";

        ## Design
        # Solid BackgroundColour behind the form (~1/3 of the screen)
        HaveFormBackground = "false";
        # left, center or right
        FormPosition = "left";
        # left, center or right; when not cropped or with a side form background
        BackgroundImageHAlignment = "center";
        BackgroundImageVAlignment = "center";
        # Unfocused elements; white or a dark grey like #444 works best
        MainColour = "white";
        # Focused/hovered/pressed elements
        AccentColour = "#EAC435";
        # User/session popups, ScreenPadding and form background
        BackgroundColour = "#444";
        # Login button text colour, if it's hard to read
        OverrideLoginButtonTextColour = "";
        # Multiplier for popup shadows; keep at or below ~5–7
        InterfaceShadowSize = "6";
        # 0–1 alpha of popup shadows
        InterfaceShadowOpacity = "0.6";
        # Corner radius in px for inputs and login button; empty for square
        RoundCorners = "20";
        # px of BackgroundColour border around the whole screen
        ScreenPadding = "0";
        Font = "Noto Sans";
        # Leave empty unless fonts are far too small
        FontSize = "";

        ## Locale
        # "long" or a Qt format string like "hh:mm A"
        HourFormat = "HH:mm";
        # "short" or a Qt format string like "dddd, d 'of' MMMM"
        DateFormat = "dddd, MMMM d yyyy";

        ## Text (empty = SDDM's default translation)
        # Greeting above the clock; empty to hide
        HeaderText = "Welcome!";
      };
    };
  in {
    environment.systemPackages = [sddmTheme];

    services.displayManager.sddm = {
      enable = true;
      theme = sddmTheme.themeName;
      extraPackages = with pkgs; [
        kdePackages.sddm-kcm
        # QML modules the theme imports, so the greeter can load it
        kdePackages.qt5compat
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
      ];
      # "Virtual Keyboard" button needs Qt's in-process virtual keyboard.
      settings.General.InputMethod = "qtvirtualkeyboard";
      autoNumlock = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
  };
}
