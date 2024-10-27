{ pkgs, ... }: {
    imports = [
        ./alvr.nix
        ./wivrn.nix
    ];

    environment.systemPackages = with pkgs; [
        sidequest
    ];
}
