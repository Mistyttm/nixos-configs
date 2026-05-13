{ inputs, self, ... }:
{
  flake.nixosModules.sddm =
    { pkgs, lib, ... }:
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
