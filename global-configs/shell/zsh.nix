{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autocd = true;
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
}
