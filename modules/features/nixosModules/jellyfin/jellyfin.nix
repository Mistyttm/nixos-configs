{...}: {
  flake.nixosModules.jellyfin-service = {pkgs, ...}: {
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
