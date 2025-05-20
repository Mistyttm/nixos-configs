{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.gaming.vr;
  mkIfElse =
    p: yes: no:
    lib.mkMerge [
      (lib.mkIf p yes)
      (lib.mkIf (!p) no)
    ];

  base = cfg.wivrn.package;

  forSlimeVR = base.overrideAttrs (old: rec {
    version = cfg.slimevr.commitHash;
    src = pkgs.fetchFromGitHub {
      owner = "notpeelz";
      repo = "WiVRn";
      rev = version;
      hash = cfg.slimevr.wivrnSlimeHash;
    };
    monado = old.monado.overrideAttrs (older: rec {
      src = pkgs.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "monado";
        repo = "monado";
        rev = cfg.slimevr.monado.rev;
        hash = cfg.slimevr.monado.hash;
      };
    });
    cmakeFlags = old.cmakeFlags ++ [
      (lib.cmakeBool "WIVRN_FEATURE_SOLARXR" true)
    ];
  });

in
{
  options.gaming.vr = {
    enable = lib.mkEnableOption "Enable VR for this system";
    wivrn = {
      enable = lib.mkEnableOption "Enable wivrn";
      package = lib.mkOption {
        type = pkgs.lib.types.package;
        default = pkgs.wivrn;
        example = pkgs.wivrn;
        description = ''
          The package to use for wivrn
        '';
      };
      encoder = lib.mkOption {
        type = lib.types.str;
        default = "nvenc";
        example = "nvenc";
        description = ''
          The encoder to use for wivrn
        '';
      };
      overlay = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression "[ pkgs.wlx-overlay-s ]";
        description = ''
          List of overlays to add to the system for wivrn
        '';
      };

    };
    slimevr = {
      enable = lib.mkEnableOption "Enable SlimeVR";
      package = lib.mkOption {
        type = pkgs.lib.types.package;
        default = pkgs.slimevr;
        example = pkgs.slimevr;
        description = ''
          The package to use for SlimeVR
        '';
      };
      serverPackage = lib.mkOption {
        type = pkgs.lib.types.package;
        default = pkgs.slimevr-server;
        example = pkgs.slimevr-server;
        description = ''
          The package to use for SlimeVR server
        '';
      };
      commitHash = lib.mkOption {
        type = lib.types.str;
        default = "9ae42c99949d07d47b7026ff607ec161f1124958";
        example = "9ae42c99949d07d47b7026ff607ec161f1124958";
        description = ''
          The commit hash to use for WiVRn + SlimeVR
        '';
      };
      wivrnSlimeHash = lib.mkOption {
        type = lib.types.str;
        default = "sha256-suOEuWXoNfCCvQjXdf0hOxAVF6DrBcSYQgDxNKfK18A=";
        example = "sha256-suOEuWXoNfCCvQjXdf0hOxAVF6DrBcSYQgDxNKfK18A=";
        description = ''
          Hash for the package
        '';
      };
      monado = {
        rev = lib.mkOption {
          type = lib.types.str;
          default = "c80de9e7cacf2bf9579f8ae8c621d8bf16e85d6c";
          example = "c80de9e7cacf2bf9579f8ae8c621d8bf16e85d6c";
          description = ''
            The commit hash to use for monado
          '';
        };
        hash = lib.mkOption {
          type = lib.types.str;
          default = "sha256-ciH26Hyr8FumB2rQB5sFcXqtcQ1R84XOlphkkLBjzvA=";
          example = "sha256-ciH26Hyr8FumB2rQB5sFcXqtcQ1R84XOlphkkLBjzvA=";
          description = ''
            The hash to use for monado
          '';
        };
      };
    };
    additionalOpenVR = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.wlx-overlay-s ]";
      description = ''
        List of additional OpenVR packages to add to the system for wivrn
      '';
    };
    # enableSidequest = lib.mkEnableOption "Enable Sidequest";
  };

  config = lib.mkIf cfg.enable {
    services.wivrn = {
      enable = cfg.wivrn.enable;
      package =
        mkIfElse cfg.slimevr.enable
          (forSlimeVR)
          base;
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
              encoder = cfg.wivrn.encoder;
              width = 1.0;
              height = 1.0;
              offset_x = 0.0;
              offset_y = 0.0;
            }
          ];
          application = cfg.wivrn.overlay;
        };
      };
    };
    environment.systemPackages =
      cfg.wivrn.overlay
      ++ [
        pkgs.opencomposite
        pkgs.monado-vulkan-layers
        pkgs.wayvr-dashboard
      ]
      ++ lib.optional cfg.slimevr.enable cfg.slimevr.package
      ++ lib.optional cfg.slimevr.enable cfg.slimevr.serverPackage
      ++ cfg.additionalOpenVR;

    networking.firewall = lib.mkIf cfg.slimevr.enable {
      allowedTCPPorts = [ 21110 ];
      allowedUDPPorts = [
        35903
        6969
      ];
    };
  };
}
