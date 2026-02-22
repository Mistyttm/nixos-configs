{
  pkgs,
  ...
}:
{
  # Reduce shutdown hang time — prevents stuck FUSE/portal processes from
  # blocking reboot indefinitely (default is 90s, which caused a hard lockup)
  systemd.settings.Manager.DefaultTimeoutStopSec = "30s";
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=30s
  '';

  systemd.user.services = {
    noisetorch = {
      description = "Noisetorch Noise Cancelling";

      after = [
        "pipewire.service"
        "pipewire-pulse.service"
      ];
      wants = [ "pipewire.service" ];

      serviceConfig = {
        Type = "simple";
        RemainAfterExit = "yes";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3"; # Give PipeWire time to enumerate devices
        ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.usb-Razer_Inc_Razer_Seiren_Mini_UC2222L03203690-00.mono-fallback -t 95";
        ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
        Restart = "on-failure";
        RestartSec = "3s";
      };

      wantedBy = [ "default.target" ];
    };
  };
}
