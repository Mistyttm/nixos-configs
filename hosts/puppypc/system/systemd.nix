{
  pkgs,
  ...
}:
{
  systemd.user.services = {
    noisetorch = {
      description = "Noisetorch Noise Cancelling";

      requires = [
        "sys-devices-pci0000:00-0000:00:02.1-0000:03:00.0-0000:04:0c.0-0000:0e:00.0-usb1-1\\x2d5-1\\x2d5.1-1\\x2d5.1:1.0-sound-card0-controlC0.device"
      ];
      after = [
        "sys-devices-pci0000:00-0000:00:02.1-0000:03:00.0-0000:04:0c.0-0000:0e:00.0-usb1-1\\x2d5-1\\x2d5.1-1\\x2d5.1:1.0-sound-card0-controlC0.device"
        "pipewire.service" # Use "pulseaudio.service" if using PulseAudio
      ];

      serviceConfig = {
        Type = "simple";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.usb-Razer_Inc_Razer_Seiren_Mini_UC2222L03203690-00.mono-fallback -t 95";
        ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
        Restart = "on-failure";
        RestartSec = "3s";
      };

      wantedBy = [ "default.target" ];
    };
  };
}
