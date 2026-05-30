{ ... }:
{
  flake.nixosModules.sddm =
    { pkgs, ... }:
    {
      services.displayManager.sddm = {
        enable = true;
        extraPackages = with pkgs; [
          kdePackages.sddm-kcm
        ];
        autoNumlock = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
      };
    };
}
