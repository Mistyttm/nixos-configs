{ config, pkgs, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "misty";
  home.homeDirectory = "/home/misty";

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
    vencord
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
  programs.kitty = {
    enable = true;
    settings = {
      # Font
      font_family = "MesloLGM Nerd Font";
      
      # Cursor
      cursor_shape = "beam";
      cursor = "#f8f8f0";
      
      # Mouse
      mouse_hide_wait = 3;
      
      # Bell
      enable_audio_bell = true;
      bell_on_tab = "🔔 ";

      # Background and Foreground
      background = "#5a5475";
      foreground = "#f8f8f0";
      selection_background = "#f8f8f2";
      selection_foreground = "#5a5475";
      background_opacity = "0.2";
      background_blur = 1;

      # Colour Table
      color0 = "#040303";
      color1 = "#f92672";
      color2 = "#c2ffdf";
      color3 = "#e6c000";
      color4 = "#c2ffdf";
      color5 = "#ffb8d1";
      color6 = "#c5a3ff";
      color7 = "#f8f8f0";
      color8 = "#6090cb";
      color9 = "#ff857f";
      color10 = "#c2ffdf";
      color11 = "#ffea00";
      color12 = "#c2ffdf";
      color13 = "#ffb8d1";
      color14 = "#c5a3ff";
      color15 = "#f8f8f0";

      # Additional Config
      editor = "nano";
    };
  };
  programs.zsh = {
    enable = true;
    autocd = true;
    #promptInit = "eval '$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json)'";
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "battery"
        "colored-man-pages"
        "colorize"
        "command-not-found"
        "common-aliases"
        "copybuffer"
        "copyfile"
        "copypath"
        "docker"
        "docker-compose"
        "emoji"
        "gh"
        "git"
        "git-commit"
        "gitignore"
        "gpg-agent"
        "node"
        "nvm"
        "npm"
        "vscode"
        "zsh-interactive-cd"
      ];
    };
  };
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "M365Princess";
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
