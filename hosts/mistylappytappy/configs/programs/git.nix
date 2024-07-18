{ config, pkgs, ... }: {
  programs.git = {
    signing = {
      key = "DAB0FD379EA2C9AF";
      signByDefault = true;
    };
  };
}
