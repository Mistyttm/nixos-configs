{ pkgs, ... }: {
    programs.alvr = {
    enable = true;
    package = pkgs.old-alvr.alvr;
    openFirewall = true;
  };
}
