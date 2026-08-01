{...}: {
  flake.homeModules.xdg = {config, ...}: {
    home.sessionVariables = {
      XCOMPOSECACHE = "$HOME/.cache/X11/xcompose";
      NUGET_PACKAGES = "$HOME/.cache/NuGetPackages";
      CUDA_CACHE_PATH = "$HOME/.cache/nv";

      NPM_CONFIG_INIT_MODULE = "$HOME/.config/npm/config/npm-init.js";
      NPM_CONFIG_CACHE = "$HOME/.cache/npm";
      NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";

      SONARLINT_USER_HOME = "$HOME/.local/share/sonarlint";
      TERMINFO = "$HOME/.local/share/terminfo";
      TERMINFO_DIRS = "$HOME/.local/share/terminfo:/run/current-system/sw/share/terminfo:/usr/share/terminfo";

      OMNISHARPHOME = "$HOME/.config/omnisharp";
      GTK2_RC_FILES = "$HOME/.config/gtk-2.0/gtkrc";
      DOCKER_CONFIG = "$HOME/.config/docker";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=$HOME/.config/java";

      ANDROID_USER_HOME = "$HOME/.local/share/android";
      ANDROID_AVD_HOME = "$HOME/.local/share/android/avd";

      CARGO_HOME = "$HOME/.local/share/cargo";
      HISTFILE = "$HOME/.local/state/bash/history";
      PASSWORD_STORE_DIR = "$HOME/.local/share/pass";
      DOTNET_CLI_HOME = "$HOME/.local/share/dotnet";
      XCURSOR_PATH = "/run/current-system/sw/share/icons:$HOME/.local/share/icons";
      WINEPREFIX = "$HOME/.local/share/wine";
      PYTHON_HISTORY = "$HOME/.local/state/python_history";
      ZDOTDIR = "$HOME/.config/zsh";
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
      configFile."mimeapps.list".force = true;
    };

    programs.bash = {
      historyFile = "${config.xdg.stateHome}/bash/history";
    };
  };
}
