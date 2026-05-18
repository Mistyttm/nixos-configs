{ self, ... }:
{
  flake.nixosModules.thedogparkHomeManager =
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
          direnv
          eza
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

        programs.puppy.git = {
          enable = true;
        };
      };
    };
}
