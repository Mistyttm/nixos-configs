{ config, lib, pkgs, ... }: {
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    sugarCandyNix = {
        enable = true; # This set SDDM's theme to "sddm-sugar-candy-nix".
        settings = {
          # Set your configuration options here.
          Background = lib.cleanSource ./background.jpg;
          ScreenWidth = 1920;
          ScreenHeight = 1080;
          FormPosition = "left";
          HaveFormBackground = true;
          PartialBlur = true;
        };
      };

  };
}
