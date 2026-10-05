{self, ...}: {
  flake.nixosModules.foodbowlHomeManager = {lib, ...}: {
    imports = [
      self.nixosModules.homeManager
    ];

    home-manager.users.misty = {
      imports = with self.homeModules; [
        misty
        git
        gpg
        xdg
        eza
        bat
        fastfetch
        ripgrep
        # starship
        zsh
        direnv
      ];

      gpg = {
        enable = true;
        # publicKeySource = ./PuppyPC.asc;
      };

      programs.direnv-instant.enable = lib.mkForce false;

      programs.puppy = {
        # starship.hostname = config.networking.hostName;
        git = {
          enable = true;
        };
      };
    };
  };
}
