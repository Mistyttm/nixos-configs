{inputs, ...}: {
  flake.nixosModules.jovian = {
    lib,
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.omniflake.flakes.jovian-nixos.nixosModules.default
    ];

    environment.systemPackages = with pkgs;
      lib.optionals (config.hardware.nvidia-custom.enable
        && config.services.desktopManager.plasma6.enable
        && lib.versionAtLeast (lib.getVersion config.hardware.nvidia.package) "615")
      # Nvidia added the driver support needed to use these applications to control VRAM
      [
        dmemcg-booster
        plasma-foreground-booster
      ];
  };
}
