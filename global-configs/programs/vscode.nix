{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = true;
      extensions = with pkgs.vscode-marketplace; [
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
        nhedger.git-reminder
        ritwickdey.liveserver
        kreativ-software.csharpextensions
        ms-dotnettools.csharp
        sonarsource.sonarlint-vscode
#         ms-dotnettools.csdevkit
#         rust-lang.rust-analyzer
        dustypomerleau.rust-syntax
        fill-labs.dependi
        swellaby.vscode-rust-test-adapter
        hbenl.vscode-test-explorer
        ms-vscode.test-adapter-converter
        tamasfe.even-better-toml
        jinxdash.prettier-rust
        ms-vscode.cpptools
      ];
      userSettings = {
        editor = {
          suggestSelection = "first";
          wordWrap = "on";
          bracketPairColorization.enabled = true;
          inlineSuggest.enabled = true;
          lineHeight = 2;
          cursorSmoothCaretAnimation = "on";
          formatOnSave = true;
          formatOnSaveMode = "modificationsIfAvailable";
          linkedEditing = true;
          fontLigatures = true;
          fontFamily = "'Fira Code', 'monospace', monospace";
          formatOnType = {
            python = true;
          };
        };

        "[nix]".editor.defaultFormatter = "jnoortheen.nix-ide";
        "[css]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[javascript]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[markdown]".editor.defaultFormatter = "yzhang.markdown-all-in-one";
        "[typescript]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[typescriptreact]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[html]".editor.defaultFormatter = "esbenp.prettier-vscode";
        "[rust]".editor.defaultFormatter = "jinxdash.prettier-rust";

        vsintellicode.modify.editor.suggestSelection = "automaticallyOverrodeDefaultValue";

        git = {
          autofetch = true;
          confirmSync = false;
          openRepositoryInParentFolders = "never";
        };

        gitlens.hovers.currentLine.over = "line";

        gitlab.showPipelineUpdateNotifications = true;

        rpc = {
          appName = "Visual Studio Code";
          buttonInactiveLabel = "null";
          detailsDebugging = "Debugging {file_name}:{current_line}:{current_column}";
          buttonEnabled = true;
          buttonInactiveUrl = "null";
        };

        bracket-pair-colorizer-2.depreciation-notice = false;
        bracketPairColorizer.depreciation-notice = false;

        workbench = {
          iconTheme = "material-icon-theme";
          startupEditor = "none";
          colorTheme = "Dracula Theme";
          editorAssociations = {
            "*.jpg" = "luna.editor";
          };
          settings.applyToAllProfiles = [ "editor.fontFamily" ];
          editor.empty.hint = "hidden";
          sideBar.location = "right";
        };

        explorer = {
          confirmDragAndDrop = false;
          confirmDelete = false;
        };

        cSpell.userWords = [
          "dotenv"
          "Emmey"
          "pjson"
        ];

        security.workspace.trust.untrustedFiles = "open";

        remote.SSH.remotePlatform."192.168.0.75" = "linux";

        sonarlint = {
          analyzerProperties = { };
          rules = {
            "javascript:S6478".level = "off";
            "typescript:S6544".level = "off";
          };
          ls = {
            javaHome = "${pkgs.jdk17}";
          };
          disableTelemetry = true;
          pathToNodeExecutable = "${pkgs.nodejs}/bin/node";
        };

        makefile.compileCommandsPath = ".vscode/compile_commands.json";

        files = {
          autoSave = "afterDelay";
          eol = "\n";
        };

        C_Cpp.codeAnalysis.clangTidy.headerFilter = "";

        vsicons.dontShowNewVersionMessage = true;

        redhat.telemetry.enabled = false;

        terminal = {
          integrated = {
            gpuAcceleration = "off";
            fontFamily = "MesloLGM Nerd Font mono";
          };
        };

        csharp.suppressHiddenDiagnostics = false;

        github = {
          copilot.enable = {
            "*" = true;
            yaml = false;
            plaintext = true;
            markdown = true;
            javascript = false;
            csharp = false;
          };
        };

        javascript = {
          inlayHints = {
            functionLikeReturnTypes.enabled = true;
            parameterNames.enabled = "all";
            parameterTypes.enabled = true;
            propertyDeclarationTypes.enabled = true;
          };
          updateImportsOnFileMove.enabled = "always";
        };

        typescript = {
          inlayHints = {
            parameterNames.enabled = "all";
            parameterTypes.enabled = true;
            propertyDeclarationTypes.enabled = true;
          };
          updateImportsOnFileMove.enabled = "always";
        };

        diffEditor.ignoreTrimWhitespace = false;

        githubPullRequests.pullBranch = "never";

        direnv.restart.automatic = true;

        latex-workshop.formatting.latex = "latexindent";

        liveServer.settings.donotVerifyTags = true;

        prettier = {
          bracketSameLine = true;
          tabWidth = 4;
        };

        nixEnvSelector = {
          useFlakes = true;
        };

        nix = {
          enableLanguageServer = true;
          formatterPath = "nixfmt";
          serverSettings = {
            autofetch = true;
            nil.formatting.command = [ "nixfmt" ];
          };
        };
      };
      keybindings = [
        {
          key = "ctrl+alt+f";
          command = "prettier.forceFormatDocument";
        }
        {
          key = "ctrl+shift+down";
          command = "editor.action.copyLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+shift+alt+down";
          command = "-editor.action.copyLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+shift+alt+down";
          command = "editor.action.insertCursorBelow";
          when = "editorTextFocus";
        }
        {
          key = "ctrl+shift+down";
          command = "-editor.action.insertCursorBelow";
          when = "editorTextFocus";
        }
      ];
    };
  };
}
