{ pkgs, ... }: let
    moe-theme = pkgs.stdenv.mkDerivation {
    pname = "moe-theme";
    version = "latest";
    src = pkgs.fetchgit {
      url = "https://gitlab.com/jomada/moe-theme";
      rev = "39215b6305af3ecec67d8c6dd2c2721f60c23594";
      hash = "sha256-a6L8xSzW8yMXTfcZF08Gv3b0Q/Leb+/D3ln/ISHmLbk=";
    };
    installPhase = ''
      mkdir -p $out/share/plasma
      cp -aR * $out/share/plasma
    '';
  };
 in{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ./swaywm/default.nix
    ../../global-configs/shell/default.nix
    ./plasma-manager.nix
  ];

  home.packages = with pkgs; [
    fastfetch
    git
    nwg-dock
    nwg-menu
    nwg-drawer
    moe-theme
  ];

  home.stateVersion = "24.11";

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#swaytest";
    upgrade = "/home/misty/nixos-configs && nix flake upgrade && sudo nixos-rebuild switch --flake .#sw   aytest";
  };

  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}
