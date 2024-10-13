{ pkgs }: {
  tela-circle-icons = import ./tela-circle-dark-purple.nix {inherit pkgs;};
  amethyst-theme = import ./amethyst.nix {inherit pkgs;};
  illusion-splash = import ./illusion.nix {inherit pkgs;};
  dracula-cursors = import ./dracula-cursors.nix {inherit pkgs;};
  plasma6-window-title-applet = import ./window-title-applet.nix {inherit pkgs;};
}