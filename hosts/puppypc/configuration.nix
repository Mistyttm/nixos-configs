{ pkgs, ... }:

{
  imports =
    [
      ./system/default.nix
      ../../global-configs/system/default.nix
      ../../global-configs/users/misty.nix
      ../../global-configs/fonts/fonts.nix
      ../../global-configs/system/nixoptions.nix
    ];

  networking.hostName = "puppypc";

  boot.supportedFilesystems = [ "ntfs" ];


  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };

  services.flatpak.enable = false;

  gaming = {
    enable = true;
    user = "misty";
    vr = {
      enable = true;
      wivrn = {
        enable = true;
        package = pkgs.wivrn;
        encoder = "nvenc";
        overlay = [ pkgs.wlx-overlay-s ];
        opencomposite = {
          override = true;
          package = pkgs.xrizer;
        };
      };
      slimevr = {
        enable = false;
        commitHash = "9ae42c99949d07d47b7026ff607ec161f1124958";
        wivrnSlimeHash = "sha256-suOEuWXoNfCCvQjXdf0hOxAVF6DrBcSYQgDxNKfK18A=";
        monado = {
          rev = "c80de9e7cacf2bf9579f8ae8c621d8bf16e85d6c";
          hash = "sha256-ciH26Hyr8FumB2rQB5sFcXqtcQ1R84XOlphkkLBjzvA=";
        };
      };
    };
    steam = {
      enable = true;
    };
    minecraft = {
      enable = true;
      jdkOverrides = with pkgs; [ jdk8 jdk17 jdk21 ];
    };
    dolphin = true;
    lutris = true;
    gamemode = true;
    cloneHero = true;
    YARG = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  virtualisation.waydroid.enable = true;

#   virtualisation.virtualbox = {
#     host.enable = true;
#     guest ={
#       enable = true;
#       clipboard = true;
#       dragAndDrop = true;
#     };
#   };

  environment = {
    systemPackages = with pkgs; [
      opencomposite
      monado-vulkan-layers
      texliveFull
      kdotool
      unityhub
      openmw
    ];
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    };
  };

  programs.adb.enable = true;

  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "freeimage-unstable-2021-11-01"
      ];
      cudaSupport = true;
    };
  };

  system.stateVersion = "25.05";

}
