# Git aspect - dendritic pattern
{ ... }:
{
  flake.modules.nixos.git =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        git
        git-lfs
        gitFull
      ];

      programs.git = {
        enable = true;
        lfs.enable = true;
      };
    };

  flake.modules.homeManager.git =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        stgit
        git-absorb
      ];

      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        settings = {
          user = {
            name = "Mistyttm";
            email = "contact@mistyttm.dev";
          };
          credential.helper = "libsecret";
          pull = {
            rebase = true;
          };
          core = {
            compression = 9;
          };
          transfer.fsckObjects = true;
          fetch.fsckobjects = true;
          receive.fsckObjects = true;
          init.defaultBranch = "main";
          push = {
            default = "current";
            followtags = true;
          };
          merge = {
            conflictstyle = "zdiff3";
          };
          diff = {
            algorithm = "histogram";
            context = 10;
          };
        };
        ignores = [
          "*~"
          "*#"
          ".DS_Store"
        ];
        lfs.enable = true;
      };

      programs.gh = {
        enable = true;
      };

      programs.difftastic = {
        enable = true;
        options = {
          background = "dark";
        };
      };
    };
}
