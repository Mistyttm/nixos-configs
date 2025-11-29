# REFERENCE EXAMPLE: Git aspect (dendritic pattern)
# This file starts with _ so it won't be loaded by import-tree
# Remove the _ prefix when you want to actually use it
#
# This demonstrates the dendritic pattern:
# - One file configures the "git" aspect across ALL configuration classes
# - System-level packages in flake.modules.nixos.git
# - User-level config in flake.modules.homeManager.git
# - Shared values via let bindings (no specialArgs needed!)

{ inputs, config, ... }:
let
  # Shared values across all classes
  # These can be used in both nixos and homeManager configs
  userName = "Mistyttm";
  userEmail = "contact@mistyttm.dev";
  defaultBranch = "main";

  # You can also access shared values from other modules
  # homeVersion = config.flake.shared.homeVersion;
in
{
  # System-level configuration (NixOS)
  # This will be imported by hosts that use this aspect
  # pkgs is available here as a module argument!
  flake.modules.nixos.git =
    { pkgs, ... }:
    {
      # System packages available to all users
      environment.systemPackages = with pkgs; [
        git
        git-lfs
        gitFull
      ];

      # System-wide git config
      programs.git = {
        enable = true;
        lfs.enable = true;
      };
    };

  # User-level configuration (home-manager)
  # This will be imported by home-manager user configs
  flake.modules.homeManager.git =
    { pkgs, lib, ... }:
    {
      # User-specific packages
      home.packages = with pkgs; [
        stgit
        git-absorb
      ];

      # User git configuration
      programs.git = {
        enable = true;
        package = pkgs.gitFull;

        userName = userName;
        userEmail = userEmail;

        extraConfig = {
          init.defaultBranch = defaultBranch;
          pull.rebase = true;
          push = {
            default = "current";
            followtags = true;
          };
          core.compression = 9;
          merge.conflictstyle = "zdiff3";
          diff = {
            algorithm = "histogram";
            context = 10;
          };
          transfer.fsckObjects = true;
          fetch.fsckobjects = true;
          receive.fsckObjects = true;
        };

        ignores = [
          "*~"
          "*#"
          ".DS_Store"
        ];

        lfs.enable = true;
      };

      # Additional git-related programs
      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
        };
      };

      programs.difftastic = {
        enable = true;
        background = "dark";
      };

      programs.delta = {
        enable = false; # Disabled in favor of difftastic
        options = {
          hyperlinks = true;
          line-numbers = true;
          side-by-side = true;
        };
      };
    };

  # Optional: perSystem for custom packages or development shells
  # perSystem = { pkgs, system, ... }: {
  #   packages = {
  #     my-git-script = pkgs.writeShellScript "my-git-script" ''
  #       echo "Custom git workflow script"
  #     '';
  #   };
  # };
}
