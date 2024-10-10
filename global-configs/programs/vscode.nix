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
    userSettings = {
            "editor.suggestSelection" = "first";
            "vsintellicode.modify.editor.suggestSelection" = "automaticallyOverrodeDefaultValue";
            "gitlens.hovers.currentLine.over"= "line";
            "rpc.appName" = "Visual Studio Code";
            "rpc.buttonInactiveLabel" = "null";
            "rpc.detailsDebugging" = "Debugging {file_name}:{current_line}:{current_column}";
            "gitlab.showPipelineUpdateNotifications" = true;
            "git.autofetch" = true;
            "git.confirmSync" = false;
            "editor.wordWrap" = "on";
            "bracket-pair-colorizer-2.depreciation-notice" = false;
            "bracketPairColorizer.depreciation-notice" = false;
            "editor.bracketPairColorization.enabled" = true;
            "rpc.buttonEnabled" = true;
            "rpc.buttonInactiveUrl" = "null";
            "workbench.iconTheme" = "material-icon-theme";
            "explorer.confirmDragAndDrop" = false;
            "cSpell.userWords" = ["dotenv" "Emmey" "pjson"];
            "[json]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "workbench.editorAssociations" = {
                    "*.jpg" = "luna.editor";
            };
            "security.workspace.trust.untrustedFiles" = "open";
            "remote.SSH.remotePlatform" = {
                    "192.168.0.75" = "linux";
            };
            "explorer.confirmDelete" = false;
            "sonarlint.analyzerProperties" = {};
            "makefile.compileCommandsPath" = ".vscode/compile_commands.json";
            "files.autoSave" = "afterDelay";
            "C_Cpp.codeAnalysis.clangTidy.headerFilter" = "";
            "vsicons.dontShowNewVersionMessage" = true;
            "editor.inlineSuggest.enabled" = true;
            "workbench.startupEditor" = "none";
            "redhat.telemetry.enabled" = false;
            "terminal.integrated.gpuAcceleration" = "off";
            "csharp.suppressHiddenDiagnostics" = false;
            "github.copilot.enable" = {
                    "*" = true;
                    "yaml" = false;
                    "plaintext" = true;
                    "markdown" = true;
                    "javascript" = false;
            };
            "files.eol" = "\n";
            "[python]" = {
                    "editor.formatOnType" = true;
            };
            "[markdown]" = {
                    "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
            };
            "git.openRepositoryInParentFolders" = "never";
            "[javascript]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "prettier.bracketSameLine" = true;
            "prettier.tabWidth" = 4;
            "sonarlint.rules" = {
                    "javascript:S6478" = {
                            "level" = "off";
                    };
                    "typescript:S6544" = {
                            "level" = "off";
                    };
            };
            "editor.lineHeight" = 2;
            "editor.cursorSmoothCaretAnimation" = "on";
            "editor.formatOnSave" = true;
            "editor.formatOnSaveMode" = "modificationsIfAvailable";
            "[css]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "terminal.integrated.fontFamily" = "MesloLGM Nerd Font mono";
            "workbench.editor.empty.hint" = "hidden";
            "workbench.colorTheme" = "Dracula Theme";
            "workbench.settings.applyToAllProfiles" = ["editor.fontFamily"];
            "javascript.inlayHints.functionLikeReturnTypes.enabled" = true;
            "javascript.inlayHints.parameterNames.enabled" = "all";
            "workbench.sideBar.location" = "right";
            "[typescriptreact]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "javascript.updateImportsOnFileMove.enabled" = "always";
            "[typescript]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "nix.enableLanguageServer" = true;
            "nix.formatterPath" = "nixfmt";
            "nix.serverSettings" = {
                    "autofetch" = true;
            };
            "javascript.inlayHints.parameterTypes.enabled" = true;
            "javascript.inlayHints.propertyDeclarationTypes.enabled" = true;
            "typescript.inlayHints.parameterNames.enabled" = "all";
            "typescript.inlayHints.parameterTypes.enabled" = true;
            "typescript.inlayHints.propertyDeclarationTypes.enabled" = true;
            "diffEditor.ignoreTrimWhitespace" = false;
            "typescript.updateImportsOnFileMove.enabled" = "always";
            "githubPullRequests.pullBranch" = "never";
            "direnv.restart.automatic" = true;
    };
    ];
  };
}
