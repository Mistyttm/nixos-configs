{
  pkgs,
  ...
}:
{
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #     qemu
    sddm-sugar-dark
    libaccounts-glib
    nil
    bitwarden-desktop
    bitwarden-cli
  ];

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;
}
