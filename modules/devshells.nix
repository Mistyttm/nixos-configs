{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        packages = [
          pkgs.just
          pkgs.nixfmt
          pkgs.deadnix
          pkgs.commitizen
        ];

        commands = [
          {
            help = "Format Nix files";
            name = "fmt";
            command = "nix fmt";
          }
        ];
      };
    };
}
