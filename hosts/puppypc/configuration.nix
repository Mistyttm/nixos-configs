{
  pkgs,
  lib,
  ...
}:
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

  # No dual-boot remains on this host; avoid stale OS discovery entries.
  boot.loader.grub.useOSProber = lib.mkForce false;

  boot.kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelModules = [ "ntsync" ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  services.flatpak.enable = false;

  desktops.niri.enable = false;

  gaming = {
    enable = true;
    user = "misty";
    steam = {
      enable = true;
    };
    minecraft = {
      enable = true;
      jdkOverrides = with pkgs; [
        jdk8
        jdk17
        jdk21
        jdk25
      ];
    };
    dolphin = true;
    lutris = true;
    gamemode = true;
    cloneHero = true;
    YARG = true;
  };

  # Sunshine streaming for Moonlight clients
  services.sunshineStreaming = {
    enable = true;
    user = "misty";
    hostName = "puppypc";
    openFirewall = true;
    autoStart = true;
    # Stream all displays (0). Individual monitors can be selected in Moonlight client.
    outputName = 2;
    # Add extra apps here if needed:
    # extraApps = [
    #   {
    #     name = "Lutris";
    #     detached = [ "${pkgs.lutris}/bin/lutris" ];
    #     image-path = "lutris.png";
    #   }
    # ];
  };

  services.wivrn = {
    enable = true;
    package = pkgs.wivrn.override {
      cudaSupport = true;
    };
    openFirewall = true;
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
        application = [ pkgs.wayvr ];
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # Improve Bluetooth audio stability on this host by reducing controller
  # power-management churn and preferring classic BR/EDR audio transport.
  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      ControllerMode = "bredr";
      Experimental = true;
    };
  };
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';

  # Favor stable playback/capture under transient CPU load on this desktop.
  services.pipewire.extraConfig.pipewire."10-puppypc-stability" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 1024;
      "default.clock.min-quantum" = 256;
      "default.clock.max-quantum" = 2048;
    };
  };

  programs.virt-manager = {
    enable = true;
    package = pkgs.virt-manager;
  };

  programs.ghidra = {
    enable = false;
    gdb = true;
  };

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    icu
    libunwind
  ];

  virtualisation.waydroid.enable = true;

  environment = {
    systemPackages = with pkgs; [
      opencomposite
      monado-vulkan-layers
      texliveFull
      # kdotool
      slimevrCustom
      sops
      nixos-rebuild-ng
      heroic
      xrizer
      klassy
      steam-presence
      usbutils
      v4l-utils
      # winboat
      nvidia-vaapi-driver
      gamescope
      vulkan-hdr-layer-kwin6
      claude-vault
      blender
      easyeffects
    ];
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    };
    sessionVariables = {
      MOZ_DISABLE_RDD_SANDBOX = "1";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };

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
