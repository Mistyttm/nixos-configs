{...}: {
  flake.homeModules.zsh = {config, ...}: {
    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = "${config.xdg.configHome}/zsh";
      history.path = "${config.xdg.stateHome}/zsh/history";
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      shellAliases = {
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
        adb = "HOME=$XDG_DATA_HOME/android adb";
        nvidia-settings = "nvidia-settings --config=$XDG_CONFIG_HOME/nvidia/settings";
      };
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
          "direnv"
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
  };
}
