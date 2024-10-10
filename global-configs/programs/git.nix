{ pkgs, ... }: {
  home.packages = with pkgs; [
    stgit
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Mistyttm";
    userEmail = "contact@mistyttm.dev";
    extraConfig = {
      credential.helper = "libsecret";
      pull = {
        rebase = true;
      };
    };
    ignores = [ "*~" "*#" ];
    lfs.enable = true;
    extraConfig = {
      core = {
        compression = 9;
      };
      transfer.fsckObjects = true;
      fetch.fsckobjects = true;
      receive.fsckObjects=true;
      init.defaultBranch = "main";
      push = {
        default = "current";
        followtags = true;
      };
      merge = { conflictstyle = "zdiff3"; };
      diff = {
        algorithm = "histogram";
        context = 10;
      };
    };
    difftastic = {
        enable = true;
        background = "dark";

    };
    delta = {
    #  enable = true;
      options = {
        hyperlinks = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
  programs.gh = {
    enable = true;
  };
}
