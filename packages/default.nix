{ pkgs }: {
  tela-circle-icons = import ./tela-circle-dark-purple.nix {inherit pkgs;};
  amethyst-theme = import ./amethyst.nix {inherit pkgs;};
}