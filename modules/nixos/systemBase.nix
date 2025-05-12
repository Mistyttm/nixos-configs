{
  lib,
  options,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.system;
in
{
  options.system = {
    bootloader = mkEnableOption "Enable the GRUB 2 boot loader";
    locale = mkEnableOption "Enable locale settings";
    networking = {
      bluetooth = mkEnableOption "Enable Bluetooth";
      ssh = mkEnableOption "Enable SSH";
      networkmanager = mkEnableOption "Enable NetworkManager";
    };
    nixOptions = mkEnableOption "Enable Nix options";
    basePackages = mkEnableOption "Enable base packages including Steam and Firefox";
    services = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "gnome"
        "earlyoom"
        "pcscd"
        "resolved"
        "mullvad-vpn"
        "touchegg"
      ];
      description = ''
        List of services to enable
      '';
    };
    virtualisation = {
      docker = mkEnableOption "Enable Docker";
      libvirtd = mkEnableOption "Enable libvirtd";
      waydroid = mkEnableOption "Enable Waydroid";
      virtualbox = mkEnableOption "Enable VirtualBox";
    };
  };

  config = {
    boot = mkIf cfg.bootloader {
      initrd = {
        systemd = {
          enable = true;
        };
      };

      #plymouth = {
      # enable = true;
      # theme = "cuts";
      # themePackages = with pkgs; [
      # # By default we would install all themes
      #   (adi1090x-plymouth-themes.override {
      #     selected_themes = [ "cuts" ];
      #   })
      #  ];
      # logo = pkgs.fetchurl {
      # url = "https://nixos.org/logo/nixos-hires.png";
      # sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
      # };
      #};

      # Enable "Silent Boot"
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };
        grub = {
          enable = true;
          efiSupport = true;
          devices = [ "nodev" ];
          useOSProber = true;
        };
        timeout = 5;
      };
    };

  };
}
