{ ... }:
{
  services.dispatcharr = {
    enable = true;
    openFirewall = true;

    group = "media";

    database = {
      type = "postgresql";
      createLocally = true;
    };

    redis.createLocally = true;
  };
}
