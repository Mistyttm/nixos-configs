{ pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    package = pkgs.oh-my-posh;
    enableZshIntegration = true;
    useTheme = "M365Princess";
  };
}
