{ inputs, self, ... }:
{
  flake.homeModules.git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.programs.puppy.git = {
        enable = lib.mkEnableOption "git config";
        signingKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "GPG signing key for git commits. If set, commits will be signed by default.";
        };
      };

      config = lib.mkIf config.programs.puppy.git.enable {
        home.packages = [ pkgs.stgit ];

        programs.git = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.git;
          signing = lib.mkIf (config.programs.puppy.git.signingKey != null) {
            key = config.programs.puppy.git.signingKey;
            signByDefault = true;
          };
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
          lfs.enable = true;
          ignores = [
            "*~"
            "*#"
          ];
        };

        programs.gh.enable = true;

        programs.difftastic = {
          enable = true;
          options = {
            background = "dark";
          };
        };
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.git = inputs.wrapper-modules.wrappers.git.wrap {
        inherit pkgs;
        package = pkgs.gitFull;

        extraPackages = [ pkgs.gitFull ];

        settings = {
          user = {
            name = "Mistyttm";
            email = "contact@mistyttm.dev";
          };
          credential.helper = "libsecret";
          pull.rebase = true;
          core = {
            compression = 9;
            excludesfile = builtins.toFile "gitignore" ''
              *~
              *#
            '';
          };
          transfer.fsckObjects = true;
          fetch.fsckobjects = true;
          receive.fsckObjects = true;
          init.defaultBranch = "main";
          push = {
            default = "current";
            followtags = true;
          };
          merge.conflictstyle = "zdiff3";
          diff = {
            algorithm = "histogram";
            context = 10;
          };
        };
      };
    };
}
