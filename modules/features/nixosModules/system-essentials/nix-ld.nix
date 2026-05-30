{ ... }:
{
  flake.nixosModules.nix-ld =
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          zlib
          openssl
          icu
          libunwind
        ];
      };
    };
}
