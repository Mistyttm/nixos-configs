{ self, ... }:
{
  flake.nixosModules.thepetshopInstaller =
    {
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix")
        self.nixosModules.system-essentials
      ];

      networking.hostName = "thepetshop";

      # Improve compatibility on varied hardware (especially Wi-Fi adapters).
      hardware.enableAllFirmware = true;
      nixpkgs.config.allowUnfree = true;

      programs.git.enable = true;
      environment.systemPackages = with pkgs; [
        just
        nh
      ];

      boot.zfs.forceImportRoot = false;

      system.stateVersion = "25.11";
    };
}
