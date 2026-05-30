{ self, ... }:
{
  flake.nixosModules.prismlauncher =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.prismlauncher
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.prismlauncher = pkgs.prismlauncher.override {
        jdks = with pkgs; [
          jdk8
          jdk17
          jdk21
        ];
      };
    };
}
