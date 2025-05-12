{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #     zed-editor
    pkg-config
    openssl
    #     godot_4
    python3
  ];

  programs.emacs = {
    enable = false;
    package = pkgs.emacs; # replace with pkgs.emacs-gtk, or a version provided by the community overlay if desired.
  };
}
