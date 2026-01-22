{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.hardware.nvidia-custom;
in
{
  options.hardware.nvidia-custom = {
    enable = lib.mkEnableOption "Custom Nvidia configuration";

    driverChannel = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "beta"
        "latest"
      ];
      default = "stable";
      description = "Which Nvidia driver channel to use.";
    };

    open = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use the open source kernel modules.";
    };

    modesetting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable modesetting (required for most setups).";
    };

    powerManagement = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Nvidia power management.";
      };

      finegrained = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable fine-grained power management (Turing+).";
      };
    };

    prime = {
      enable = lib.mkEnableOption "PRIME offload for laptops";

      intelBusId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "PCI bus ID of Intel GPU (e.g., 'PCI:0:2:0').";
      };

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "PCI bus ID of Nvidia GPU (e.g., 'PCI:1:0:0').";
      };
    };

    forceFullCompositionPipeline = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Force full composition pipeline (fixes tearing on some setups).";
    };

    blacklistNova = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Blacklist the Nova/NovaCore driver (kernel 6.18+) which conflicts with proprietary driver.";
    };

    extraGraphicsPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to add to hardware.graphics.extraPackages.";
    };

    nvidiaContainerToolkit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the NVIDIA container toolkit for docker";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;
    hardware.graphics.extraPackages =
      with pkgs;
      [
        monado-vulkan-layers
        vulkan-hdr-layer-kwin6
      ]
      ++ cfg.extraGraphicsPackages;

    services.xserver.videoDrivers = [ "nvidia" ];

    boot.blacklistedKernelModules = lib.mkIf cfg.blacklistNova [
      "nova"
      "novacore"
      "nova_core"
      "nouveau"
    ];

    boot.kernelParams = lib.mkIf cfg.blacklistNova [
      "module_blacklist=nova_core,nova,novacore"
    ];

    hardware.nvidia = {
      modesetting.enable = cfg.modesetting;
      powerManagement.enable = cfg.powerManagement.enable;
      powerManagement.finegrained = cfg.powerManagement.finegrained;
      open = cfg.open;
      nvidiaSettings = true;
      forceFullCompositionPipeline = cfg.forceFullCompositionPipeline;

      prime = lib.mkIf cfg.prime.enable {
        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };

      package =
        if cfg.driverChannel == "beta" then
          config.boot.kernelPackages.nvidiaPackages.beta
        else if cfg.driverChannel == "latest" then
          config.boot.kernelPackages.nvidiaPackages.latest
        else
          config.boot.kernelPackages.nvidiaPackages.stable;
    };

    hardware.nvidia-container-toolkit.enable = cfg.nvidiaContainerToolkit;
  };
}
