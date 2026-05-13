{ self, inputs, ... }:
{
  flake.nixosModules.thekennelHomeManager =
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
          eza
          fastfetch
          ripgrep
          starship
          zsh
          kitty
          direnv
          kdeconnect
        ];

        gpg = {
          enable = true;
          publicKeySource = ./PuppyPC.asc;
        };

        programs.puppy.git = {
          enable = true;
        };
      };
    };
}
