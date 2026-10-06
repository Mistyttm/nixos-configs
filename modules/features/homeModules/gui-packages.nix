{...}: {
  flake.homeModules.gui-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      libsecret
      slack
      obsidian
      vlc
      thunderbird-bin
      libreoffice-qt
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
