{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  environment.systemPackages = with pkgs.kdePackages; [
    plasma-browser-integration
    kio
    kio-fuse
    kio-extras
    kio-gdrive
    kaccounts-integration
    kaccounts-providers
    signond
    accounts-qt
    signon-kwallet-extension
    kalk
    skanpage
  ];

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "au";
      variant = "";
    };
  };
}
