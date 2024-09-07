{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    unstable.zed-editor
    pkg-config
    openssl
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;  # replace with pkgs.emacs-gtk, or a version provided by the community overlay if desired.
  };
}
