{ pkgs, kwin-effects-forceblur, ... }:
let
  slimevrCustom = pkgs.slimevr.overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup or ""}

      wrapProgram "$out/bin/slimevr" \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1
    '';
  });
in
{
  imports = [
    ./system/default.nix
    ../../global-configs/system/default.nix
    ../../global-configs/users/misty.nix
    ../../global-configs/fonts/fonts.nix
    ../../global-configs/system/nixoptions.nix
  ];

  networking.hostName = "puppypc";

  boot.supportedFilesystems = [ "ntfs" ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

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
#     vr = {
#       enable = false;
#       wivrn = {
#         enable = true;
#         package = pkgs.wivrn;
#         encoder = "nvenc";
#         overlay = [ pkgs.wlx-overlay-s ];
#       };
#       slimevr = {
#         enable = false;
# #         commitHash = "9ae42c99949d07d47b7026ff607ec161f1124958";
# #         wivrnSlimeHash = "sha256-suOEuWXoNfCCvQjXdf0hOxAVF6DrBcSYQgDxNKfK18A=";
# #         monado = {
# #           rev = "c80de9e7cacf2bf9579f8ae8c621d8bf16e85d6c";
# #           hash = "sha256-ciH26Hyr8FumB2rQB5sFcXqtcQ1R84XOlphkkLBjzvA=";
# #         };
#       };
#       additionalOpenVR = [
#         pkgs.xrizer
#       ];
#     };
    steam = {
      enable = true;
    };
    minecraft = {
      enable = true;
      jdkOverrides = with pkgs; [
        jdk8
        jdk17
        jdk21
      ];
    };
    dolphin = true;
    lutris = true;
    gamemode = true;
    cloneHero = true;
    YARG = true;
  };

  services.wivrn = {
      enable = true;
      package = pkgs.wivrn;
      openFirewall = true;
      defaultRuntime = true;
      autoStart = true;
      config = {
        enable = true;
        json = {
          scale = 1.0;
          bitrate = 50000000;
          encoders = [
            {
              encoder = "nvenc";
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
          application = [ pkgs.wlx-overlay-s ];
        };
      };
    };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  programs.ghidra = {
    enable = true;
    gdb = true;
  };

  virtualisation.waydroid.enable = false;

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
#       unityhub
      openmw
      slimevrCustom
      sops
      nixos-rebuild-ng
      heroic
      opencomposite
      monado-vulkan-layers
#       wayvr-dashboard
      xrizer
      klassy
    ] ++ [
      kwin-effects-forceblur.packages.${pkgs.system}.default
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
        "libsoup-2.74.3"
      ];
      cudaSupport = true;
    };
  };

  system.stateVersion = "25.11";

}
