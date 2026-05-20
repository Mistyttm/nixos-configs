{ self, ... }:
{
  flake.homeModules.starship =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.programs.puppy.starship.hostname = lib.mkOption {
        type = lib.types.str;
        description = "Hostname used to select the Starship package variant";
      };

      config = {
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
          package =
            self.packages.${pkgs.stdenv.hostPlatform.system}."${config.programs.puppy.starship.hostname}Starship";
        };
      };
    };
}
