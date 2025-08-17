{ config, ... }:
{
  sops.secrets."STEAM_API_KEY" = {
    sopsFile = ../../../secrets/steam.yaml;
    owner = config.users.users.misty.name;
    group = config.users.users.misty.group;
  };

  programs.steam-presence = {
    enable = true;
    autoStart = true;

    # Optional: custom settings
    settings = {
      STEAM_API_KEY = ;
    };
  };
}
