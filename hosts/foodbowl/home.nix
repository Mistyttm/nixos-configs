{ homeVersion, ... }:
{
  # TODO please change the username & home directory to your own
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ../../global-configs/programs/git.nix
    ../../global-configs/programs/xdg.nix
    ../../global-configs/programs/cli.nix
    ../../global-configs/programs/fastfetch.nix
  ];

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
