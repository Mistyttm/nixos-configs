{ pkgs, ... }: let
    tela-circle-theme = pkgs.stdenv.mkDerivation {
    pname = "tela-circle-theme";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      repo = "https://github.com/vinceliuice/Tela-icon-theme";
      owner = "vinceliuice";
      rev = "80b86a4a57ab243ec16c5c27b920f3544706955d";
      hash = "";
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
    tela-circle-theme
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
