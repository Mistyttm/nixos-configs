{ pkgs, vsc-extensions, ... }: {
programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with vsc-extensions.vscode-marketplace; [
        formulahendry.auto-rename-tag
        aaron-bond.better-comments
        matthiasschedel.bibtex-manager
        mkhl.direnv
        leonardssh.vscord
        mikestead.dotenv
        dracula-theme.theme-dracula
        editorconfig.editorconfig
        dbaeumer.vscode-eslint
        toba.vsfire
        waderyan.gitblame
        donjayamanne.githistory
        github.vscode-github-actions
        github.copilot
        github.copilot-chat
        github.vscode-pull-request-github
        george-alisson.html-preview-vscode
        ecmel.vscode-html-css
        hwencc.html-tag-wrapper
        orta.vscode-jest
        james-yu.latex-workshop
        yzhang.markdown-all-in-one
        yzane.markdown-pdf
        bierner.github-markdown-preview
        davidanson.vscode-markdownlint
        pkief.material-icon-theme
        arrterian.nix-env-selector
        jnoortheen.nix-ide
        christian-kohler.npm-intellisense
        christian-kohler.path-intellisense
        esbenp.prettier-vscode
        yoavbls.pretty-ts-errors
        ms-python.vscode-pylance
        ms-python.python
        ms-python.debugpy
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode.remote-explorer
        bradlc.vscode-tailwindcss
        vitest.explorer
        redhat.vscode-yaml
    ];
    ];
  };
}
