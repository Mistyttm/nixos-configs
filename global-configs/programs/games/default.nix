{ pkgs, ... }: {
#  imports = [
#  ];
  home.packages = with pkgs; [
    (prismlauncher.override { jdks = [ jdk8 jdk17 jdk21 ]; })
    protonup-qt
  ];
}
