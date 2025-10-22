{ pkgs, ... }:
{
  home.packages = with pkgs; [
    stgit
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
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
  programs.delta = {
    #  enable = true;
    options = {
      hyperlinks = true;
      line-numbers = true;
      side-by-side = true;
    };
  };
}
