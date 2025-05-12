{ ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
    };
  };
  #  xdg.configFile."gtk-2.0/gtkrc" = ./.gtkrc-2.0;
  #  xdg.dataFile."zsh/history" = ./.zsh_history;
  #  xdg.dataFile."pki" = ./.pki;
}
