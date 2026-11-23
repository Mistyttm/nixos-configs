{...}: {
  flake.nixosModules.jellyfin-service = {pkgs, ...}: {
    lantian.harden.jellyfin = {
      enable = false;
      cuda = true;
      bindPaths = [
        "/mnt/media"
        "/mnt/homework"
        "/mnt/localExpansion"
      ];
    };
    systemd.services.jellyfin.serviceConfig.PrivateDevices = false;
    environment.systemPackages = with pkgs; [
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];

    services.jellyfin = {
      enable = true;
      package = pkgs.jellyfin;
      openFirewall = true;
      user = "jellyfin";
      group = "jellyfin";
      dataDir = "/var/lib/jellyfin";
      configDir = "/var/lib/jellyfin/config";
    };

    users.users.jellyfin.extraGroups = ["media"];
  };
}
