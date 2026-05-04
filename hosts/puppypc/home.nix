{ ... }:
{
  imports = [
    ../../global-configs/home-base.nix
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.shellAliases = {
    rebuild = "NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake update && NH_SHOW_ACTIVATION_LOGS=1 nh os switch . -H puppypc";
  };

  # Avoid activation failures when a previous mimeapps.list.backup already exists.
  xdg.configFile."mimeapps.list".force = true;
}
