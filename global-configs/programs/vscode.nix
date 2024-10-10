{ pkgs, vsc-extensions, ... }: {
programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    extensions = with pkgs.unstable.vscode-extensions; [
      ms-python.python
      formulahendry.auto-rename-tag
      aaron-bond.better-comments
      mkhl.direnv
      leonardssh.vscord
      mikestead.dotenv
      dracula-theme.theme-dracula
      editorconfig.editorconfig
      dbaeumer.vscode-eslint
      waderyan.gitblame
      donjayamanne.githistory
      github.vscode-github-actions
      github.vscode-pull-request-github
      ecmel.vscode-html-css
      bradgashler.htmltagwrap
      james-yu.latex-workshop
      yzhang.markdown-all-in-one
      davidanson.vscode-markdownlint
      bierner.github-markdown-preview
      pkief.material-icon-theme
      arrterian.nix-env-selector
      jnoortheen.nix-ide
      christian-kohler.npm-intellisense
      christian-kohler.path-intellisense
      esbenp.prettier-vscode
      yoavbls.pretty-ts-errors
      ms-python.vscode-pylance
      ms-python.debugpy
    ];
  };
}
