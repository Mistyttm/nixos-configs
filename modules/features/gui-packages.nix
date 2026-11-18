{...}: {
  flake.homeModules.gui-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      libsecret
      slack
      obsidian
      vlc
      thunderbird-bin
      (pkgs.libreoffice-qt.override {
        unwrapped = pkgs.libreoffice-qt-unwrapped.override {
          langs = ["en-US"];
          kdeIntegration = true;
        };
      })
      zenity
      libnotify
      teams-for-linux
      python3
      nil
      vesktop
      heroic
      gimp
      qbittorrent
    ];
  };
}
