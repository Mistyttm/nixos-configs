{ ... }:
{
  flake.homeModules.gui-packages =
    { pkgs, ... }:
    {
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
        vesktop
        heroic
        gimp
        blender
        qbittorrent
      ];
    };
}
