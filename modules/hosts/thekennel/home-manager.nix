{self, ...}: {
  flake.nixosModules.thekennelHomeManager = {config, ...}: {
    imports = [
      self.nixosModules.homeManager
    ];

    home-manager.users.misty = {
      imports = with self.homeModules; [
        misty
        git
        gpg
        xdg
        direnv
        eza
        bat
        fastfetch
        ripgrep
        starship
        zsh
        direnv
      ];

      gpg = {
        enable = true;
        # publicKeySource = ./PuppyPC.asc;
      };

      programs.puppy = {
        starship.hostname = config.networking.hostName;
        git = {
          enable = true;
        };
      };
    };
  };
}
