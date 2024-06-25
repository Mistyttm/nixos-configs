{ config, pkgs, ... }: {
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
}
