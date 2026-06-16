{self, ...}: {
  flake.nixosModules.puppylaptopHomeManager = {config, ...}: {
    imports = [
      self.nixosModules.homeManager
    ];

    home-manager.users.misty = {
      imports = with self.homeModules; [
        misty
        git
        gpg
        xdg
        vscode
        easyeffects
        direnv
        gui-packages
        mangohud
        eza
        bat
        fastfetch
        ripgrep
        starship
        zsh
        kitty
        direnv
        gameModding
        linux-wallpaperengine
      ];

      gpg = {
        enable = true;
        publicKeySource = ./PuppyLaptop.asc;
      };

      programs.puppy = {
        starship.hostname = config.networking.hostName;
        git = {
          enable = true;
          signingKey = "05E283AA410E1548";
        };
      };
    };
  };
}
