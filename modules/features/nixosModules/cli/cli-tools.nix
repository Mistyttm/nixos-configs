{ ... }:
{
  flake.nixosModules.cli-tools =
    { pkgs, ... }:
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
        cabextract
        nixfmt
        nixd
        nil
        scrcpy
        file
        nixfmt
        rsync
        strace
      ];
    };
}
