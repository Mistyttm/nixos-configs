{ pkgs, ... }: {
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    # theme = "${pkgs.sddm-sugar-dark}/share/sddm/themes/sugar-dark";
  };
}

