{ config, pkgs, ... }: {
#  imports = [
#  ];
  home.packages = with pkgs; [
    (unstable.prismlauncher.override { jdks = [ jdk8 jdk17 jdk21 ]; })
    protonup-qt
  ];
}
