{ inputs, ... }:
{
  flake.nixosModules.cli-tools =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        xdg-utils
        pass
        tree
        nano
        wget
        p7zip
        zip
        tmux
        unzip
        age
        sops
        ookla-speedtest
        rar
        quickemu
        cabextract
        nixfmt
        bitwarden-cli
        nil
        libaccounts-glib
        scrcpy
        file
        nixfmt
      ];
    };
}
