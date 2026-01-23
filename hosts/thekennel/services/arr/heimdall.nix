{ config, ... }:
{
  sops.secrets."heimdall-app-key" = {
    sopsFile = ../../../../secrets/heimdall.yaml;
    owner = config.users.users.heimdall.name;
    group = config.users.users.heimdall.group;
    mode = "0400";
  };

  services.heimdall = {
    enable = true;
    appKeyFile = config.sops.secrets.heimdall-app-key.path;
    appUrl = "http://192.168.0.171:8098";
    allowInternalRequests = true;
    nginx.enable = false;
    poolConfig = {
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.start_servers" = 4;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 8;
      "pm.max_requests" = 500;
    };
  };

}
