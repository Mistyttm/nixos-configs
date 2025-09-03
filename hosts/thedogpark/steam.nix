{ homeVersion, pkgs, ... }:
{
  home.username = "steam";
  home.homeDirectory = "/var/lib/steamuser";

  imports = [
    ../../global-configs/programs/git.nix
    ../../global-configs/programs/xdg.nix
    ../../global-configs/programs/cli.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    steamcmd
    steamtui
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = homeVersion;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

}
