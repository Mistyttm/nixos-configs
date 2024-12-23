{ pkgs, ... }: {
    programs.alvr = {
    enable = true;
    package = pkgs.alvr;
    openFirewall = true;
  };
}
