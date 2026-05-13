{ inputs, ... }:
{
  flake.nixosModules.nix-ld =
    { pkgs, lib, ... }:
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
