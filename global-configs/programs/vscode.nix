{ pkgs, vsc-extensions, ... }: {
programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    ];
  };
}
