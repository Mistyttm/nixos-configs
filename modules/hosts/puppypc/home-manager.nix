{ self, ... }:
{
  flake.nixosModules.puppypcHomeManager =
    { config, ... }:
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
          zed
          easyeffects
          direnv
          kdeconnect
          gui-packages
          eza
          bat
          fastfetch
          ripgrep
          starship
          zsh
          kitty
          direnv
          kdeconnect
          gameModding
          mangohud
          linux-wallpaperengine
        ];

        gpg = {
          enable = true;
          publicKeySource = ./PuppyPC.asc;
        };

        programs.puppy = {
          starship.hostname = config.networking.hostName;
          git = {
            enable = true;
            signingKey = "5D6050A7E4497C4A";
          };
        };
      };
    };
}
