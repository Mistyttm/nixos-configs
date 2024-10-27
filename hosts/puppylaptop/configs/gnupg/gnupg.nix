{ config, ... }:

{
    # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./me/puppylaptop.asc;
        trust = "ultimate";
      }
    ];
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}