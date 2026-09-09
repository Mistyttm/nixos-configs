{...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.nixfmt;

    pre-commit = {
      settings.hooks = {
        deadnix = {
          enable = true;
          package = pkgs.deadnix;
          settings = {
            edit = true;
          };
        };
        commitizen.enable = true;
        alejandra = {
          enable = true;
          package = pkgs.alejandra;
        };
        flake-file-sync = {
          enable = true;
          name = "flake-file sync check";
          entry = "bash -c 'nix run .#write-flake && git diff --quiet -- flake.nix || (echo \"flake.nix is out of sync — run: nix run .#write-flake\" && exit 1)'";
          files = "^(modules/.*\\.nix|outputs\\.nix|flake\\.nix)$";
          pass_filenames = false;
        };
      };
    };
  };
}
