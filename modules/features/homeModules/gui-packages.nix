{...}: {
  flake.homeModules.gui-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      libsecret
      slack
      zoom-us
      obsidian
      vlc
      thunderbird-esr
      libreoffice-qt
      zenity
      libnotify
      teams-for-linux
      python3
      nil
      (vesktop.override {
        pnpm_10_29_2 = pkgs.pnpm_10;
      })
      heroic
      gimp
      blender
      qbittorrent
    ];
  };
}
