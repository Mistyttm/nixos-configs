{ config, pkgs, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ./shell/default.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    discord
    firefox
    vlc
    gh
    prismlauncher
    spotify
    spicetify-cli
    obsidian
    vscode
    zoom-us
    slack
    libsecret
    thunderbird
    nodejs_18
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Mistyttm";
    userEmail = "contact@mistyttm.dev";
    extraConfig = { credential.helper = "libsecret"; };
    signing = {
       key = null;
# 
# set this to true to require you to sign your commits by default with e.g. gpg
#      signByDefault = true;
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
  
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
    };
  };
#  xdg.configFile."gtk-2.0/gtkrc" = ./.gtkrc-2.0;
#  xdg.dataFile."zsh/history" = ./.zsh_history; 
#  xdg.dataFile."pki" = ./.pki;

  programs.fastfetch = {
    enable = true;
  };
  programs.java.enable = true;
  fonts.fontconfig.enable = true;
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

}
