{
  self,
  inputs,
  ...
}: {
  # Throwaway QEMU VM for trying the Plasma rice without touching a real host:
  #   nix run .#plasma-vm
  # Boots straight into Plasma as misty (password "test") on three virtual monitors. State lives in ./plasma-vm.qcow2; delete it to start fresh.
  perSystem = {system, ...}: {
    packages.plasma-vm =
      (inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.plasma
          self.nixosModules.sddm
          self.nixosModules.homeManager
          {
            nixpkgs = {
              hostPlatform = system;
              # nixosModules.plasma pulls in zoom-us.
              config.allowUnfree = true;
              overlays = [
                self.overlays.default
                self.overlays.kde-plasma-workspace-xdg-fix
              ];
            };

            networking.hostName = "plasma-vm";
            system.stateVersion = "26.11";

            users.users.misty = {
              isNormalUser = true;
              extraGroups = ["wheel"];
              initialPassword = "test";
            };

            services.displayManager = {
              defaultSession = "plasma";
              autoLogin = {
                enable = true;
                user = "misty";
              };
            };

            home-manager.users.misty = {
              imports = [self.homeModules.plasmaManager];
              programs.puppy.plasma.dockScreens = [0 1];
            };

            virtualisation.vmVariant.virtualisation = {
              memorySize = 6144;
              cores = 4;
              qemu.options = [
                "-vga none"
                "-device virtio-vga,max_outputs=3,xres=1920,yres=1080"
              ];
            };
          }
        ];
      }).config.system.build.vm;
  };
}
