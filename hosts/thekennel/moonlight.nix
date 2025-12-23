# Moonlight streaming client setup - replaces Jovian NixOS
# This configures thekennel as a Moonlight client that connects to puppypc
{
  pkgs,
  lib,
  ...
}:
{
  # Install Moonlight and related packages
  environment.systemPackages = with pkgs; [
    moonlight-qt
    libdecor # Wayland decorations
  ];

  # Auto-login for seamless boot-to-stream experience
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "misty";
    };
  };

  # Disable screen blanking/power management for always-on streaming
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xset}/bin/xset s off
    ${pkgs.xorg.xset}/bin/xset -dpms
    ${pkgs.xorg.xset}/bin/xset s noblank
  '';

  # Keep the useful SteamOS-like system tweaks from Jovian
  # Zram for better memory management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Early OOM killer to prevent system freezes
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
  };

  # System performance tweaks
  boot.kernel.sysctl = {
    # Reduce swap tendency
    "vm.swappiness" = 10;
    # Better responsiveness under memory pressure
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # Nvidia environment variables (kept from Jovian config)
  environment.sessionVariables = {
    # Disable hardware cursors - critical for Nvidia
    WLR_NO_HARDWARE_CURSORS = "1";
    KWIN_FORCE_SW_CURSOR = "1";

    # Nvidia-specific fixes
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    __GL_SYNC_TO_VBLANK = "1";
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
  ];

  # Systemd user service to auto-start Moonlight on login
  # This connects to puppypc automatically
  systemd.user.services.moonlight-autostart = {
    description = "Auto-start Moonlight to connect to puppypc";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      # Wait a moment for the desktop to fully initialize
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${lib.getExe pkgs.moonlight-qt}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
