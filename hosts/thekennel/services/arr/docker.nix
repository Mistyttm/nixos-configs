{ config, pkgs, ... }:
let
  nasRoot = "/mnt/media";
  localRoot = "/mnt/localExpansion";
in
{
  environment.systemPackages = with pkgs; [
    nvidia-docker
  ];

  users.groups.tdarr = { };

  users.users.tdarr = {
    isSystemUser = true;
    group = "tdarr";
    uid = 985;
    extraGroups = [
      "media"
      "docker"
      "video"
    ]; # video group for GPU access
    description = "Tdarr service user";
    home = "/var/lib/tdarr";
    createHome = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      tdarr = {
        image = "ghcr.io/haveagitgat/tdarr:latest";
        autoStart = true;

        ports = [
          "8265:8265"
          "8266:8266"
        ];

        environment = {
          TZ = "Australia/Brisbane";
          PUID = toString config.users.users.tdarr.uid;
          PGID = toString config.users.groups.media.gid;
          UMASK_SET = "002";
          serverIP = "0.0.0.0";
          serverPort = "8266";
          webUIPort = "8265";
          internalNode = "true";
          inContainer = "true";
          ffmpegVersion = "6";
          nodeName = "InternalNode";
        };

        volumes = [
          "/data/tdarr/server:/app/server"
          "/data/tdarr/configs:/app/configs"
          "/data/tdarr/logs:/app/logs"
          "${localRoot}/tdarr:/temp"
          # Your 4 media libraries
          "${nasRoot}/TV:/media/TV"
          "${nasRoot}/Movies:/media/Movies"
          "${localRoot}/tv:/media/tv"
          "${localRoot}/movies:/media/movies"
        ];

        extraOptions = [
          "--device=nvidia.com/gpu=all"
          "--network=bridge"
        ];
      };

      tdarr-node = {
        image = "ghcr.io/haveagitgat/tdarr_node:latest";
        autoStart = true;

        environment = {
          TZ = "Australia/Brisbane";
          PUID = toString config.users.users.tdarr.uid;
          PGID = toString config.users.groups.media.gid;
          UMASK_SET = "002";
          nodeName = "ExternalNode";
          serverIP = "0.0.0.0";
          serverPort = "8266";
          inContainer = "true";
          ffmpegVersion = "6";
          NVIDIA_VISIBLE_DEVICES = "all";
        };

        volumes = [
          "/data/tdarr/configs:/app/configs"
          "/data/tdarr/logs:/app/logs"
          "${localRoot}/tdarr:/temp"
          # Your 4 media libraries
          "${nasRoot}/TV:/media/TV"
          "${nasRoot}/Movies:/media/Movies"
          "${localRoot}/tv:/media/tv"
          "${localRoot}/movies:/media/movies"
        ];

        extraOptions = [
          "--device=nvidia.com/gpu=all"
          "--network=container:tdarr"
        ];

        dependsOn = [ "tdarr" ];
      };
    };
  };

  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/tdarr 0755 tdarr tdarr -"
    "d /var/lib/tdarr/server 0755 tdarr tdarr -"
    "d /var/lib/tdarr/configs 0755 tdarr tdarr -"
    "d /var/lib/tdarr/logs 0755 tdarr tdarr -"
    "d ${localRoot}/tdarr 0755 tdarr media -"
  ];
}
