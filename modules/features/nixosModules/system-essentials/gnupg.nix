{ ... }:
{
  flake.nixosModules.gnupg =
    {
      config,
      pkgs,
      ...
    }:
    let
      cliHosts = [
        "thekennel"
        "thedogpark"
      ];
      isCliHost = builtins.elem config.networking.hostName cliHosts;
    in
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = if isCliHost then pkgs.pinentry-curses else pkgs.pinentry-qt;
      };
    };
}
