{ config, pkgs, ... }: {
  programs.git = {
    signing = {
      key = "5D6050A7E4497C4A";
      signByDefault = true;
    };
  };
}
