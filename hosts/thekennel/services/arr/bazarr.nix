{ ... }:
{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "bazarr";
    user = "bazarr";
  };
}
