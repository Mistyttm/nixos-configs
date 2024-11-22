{ pkgs, ... }: {
    imports = [
#         ./alvr.nix
        ./wivrn.nix
        ./monado.nix
    ];

    environment.systemPackages = with pkgs; [
        sidequest
    ];
}
