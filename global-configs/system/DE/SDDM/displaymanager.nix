{ pkgs, ... }: {
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    extraPackages = with pkgs; [
      kdePackages.sddm-kcm
    ];
    settings = {
      AutoLogin = {
        Session = "plasma.desktop";
        User = "misty";
      };
    };
    autoNumlock = true;
  };
}

