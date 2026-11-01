{inputs, ...}: {
  flake.nixosModules.gpu-screenrecorder = {...}: {
    # NixOS/nixpkgs#580322 reworks the module alongside the packages in the
    # nixpkgs-prs overlay. Remove both lines when that entry goes.
    disabledModules = ["programs/gpu-screen-recorder.nix"];
    imports = ["${inputs.nixpkgs-pr-580322}/nixos/modules/programs/gpu-screen-recorder.nix"];

    programs.gpu-screen-recorder = {
      enable = true;
      ui = {
        enable = true;
      };
    };
  };
}
