{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nvidia-docker
  ];

  users.groups.dispatcharr = { };

  users.users.dispatcharr = {
    isSystemUser = true;
    group = "dispatcharr";
    extraGroups = [ "media" ];
    description = "Dispatcharr service user";
    home = "/var/lib/dispatcharr";
    createHome = true;
  };

  networking.firewall.allowedTCPPorts = [
    9191
  ];

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      dispatcharr = {
        image = "ghcr.io/dispatcharr/dispatcharr:latest";
        autoStart = true;

        ports = [
          "9191:9191"
        ];

        environment = {
          TZ = "Australia/Brisbane";
          DISPATCHARR_ENV = "aio";
          REDIS_HOST = "localhost";
          CELERY_BROKER_URL = "redis://localhost:6379/0";
          DISPATCHARR_LOG_LEVEL = "info";
        };

        volumes = [
          "/data/dispatcharr:/data"
        ];

        extraOptions = [
          "--network=bridge"
        ];
      };

    };
  };

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/dispatcharr 0755 dispatcharr dispatcharr -"
    "d /data/dispatcharr 0755 dispatcharr media -"
  ];
}
