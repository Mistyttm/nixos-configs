{ pkgs, ... }: {
    imports = [
#         ./alvr.nix
        ./wivrn.nix
#         ./monado.nix
    ];

    environment.systemPackages = with pkgs; [
        sidequest
        wlx-overlay-s
    ];

    programs.envision = {
        enable = false;
        openFirewall = true; # This is set true by default
    };
}
