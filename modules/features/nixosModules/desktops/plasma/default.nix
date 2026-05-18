{ ... }:
{
  flake.nixosModules.plasma =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;

      # printing
      services.printing.enable = true;

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        konsole
        kwin-x11
      ];

      environment.systemPackages =
        with pkgs.kdePackages;
        [
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
          filelight
          # wallpaper-engine-plugin
        ]
        ++ [
          pkgs.darkly
          pkgs.plasma-panel-colorizer
          pkgs.klassy
        ];
    };
}
