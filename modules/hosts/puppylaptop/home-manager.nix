{ self, inputs, ... }:
{
  flake.nixosModules.puppylaptopHomeManager =
    { ... }:
    {
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
          kdeconnect
          gui-packages
          mangohud
          eza
          fastfetch
          ripgrep
          starship
          zsh
          kitty
          direnv
          kdeconnect
          gameModding
          linux-wallpaperengine
        ];

        gpg = {
          enable = true;
          publicKeySource = ./PuppyLaptop.asc;
        };

        programs.puppy.git = {
          enable = true;
          signingKey = "5D6050A7E4497C4A";
        };
      };
    };
}
