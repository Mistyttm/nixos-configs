{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.sunshineStreaming;

  # Helper utility for launching Steam games from Sunshine. This works around
  # an issue where Sunshine's security wrapper prevents Steam from launching.
  # Examples:
  #   steam-run-url steam://rungameid/1086940  # Start Baldur's Gate 3
  #   steam-run-url steam://open/bigpicture    # Start Steam in Big Picture mode
  #   steam-run-url steam://open/gamepadui     # Start Steam Deck UI
  steam-run-url = pkgs.writeShellApplication {
    name = "steam-run-url";
    text = ''
      echo "$1" > "/run/user/$(id --user)/steam-run-url.fifo"
    '';
    runtimeInputs = [
      pkgs.coreutils # For `id` command
    ];
  };

  # Script that launches Steam and waits for it, so Sunshine can track it
  steam-launch-and-wait = pkgs.writeShellApplication {
    name = "steam-launch-and-wait";
    text = ''
      # Write the URL to the FIFO to launch Steam
      echo "$1" > "/run/user/$(id --user)/steam-run-url.fifo"
      # Wait a moment for Steam to start
      sleep 2
      # Wait for Steam to exit by monitoring the process
      while pgrep -x "steam" > /dev/null || pgrep -f "steam.*.sh" > /dev/null; do
        sleep 1
      done
    '';
    runtimeInputs = [
      pkgs.coreutils
      pkgs.procps
    ];
  };
in
{
  options.services.sunshineStreaming = {
    enable = mkEnableOption "Enable Sunshine streaming with Steam workaround";

    hostName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "The name of this host as seen in Moonlight";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the firewall for Sunshine";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start Sunshine automatically on login";
    };

    user = mkOption {
      type = types.str;
      default = "misty";
      description = "The user to configure the steam-run-url service for";
    };

    extraApps = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "Additional applications to add to Sunshine";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional settings for Sunshine";
    };

    outputName = mkOption {
      type = types.either types.int types.str;
      default = 0;
      description = "The display output to stream (0 = all displays, or use display number/name)";
    };
  };

  config = mkIf cfg.enable {
    # Main Sunshine service configuration
    services.sunshine = {
      enable = true;
      autoStart = cfg.autoStart;
      capSysAdmin = true; # Required for Wayland
      openFirewall = cfg.openFirewall;

      settings = {
        sunshine_name = cfg.hostName;
        output_name = cfg.outputName;
        key_rightalt_to_key_win = "enabled";
      }
      // cfg.extraSettings;

      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
          {
            name = "Steam Big Picture";
            # Use cmd instead of detached so Sunshine tracks the process
            cmd = "${lib.getExe steam-launch-and-wait} steam://open/bigpicture";
            # Close Big Picture when the stream ends
            undo = "${lib.getExe steam-run-url} steam://close/bigpicture";
            image-path = "steam.png";
          }
          {
            name = "Steam Deck UI";
            # Use cmd instead of detached so Sunshine tracks the process
            cmd = "${lib.getExe steam-launch-and-wait} steam://open/gamepadui";
            # Close gamepad UI when the stream ends
            undo = "${lib.getExe steam-run-url} steam://close/gamepadui";
            image-path = "steam.png";
          }
        ]
        ++ cfg.extraApps;
      };
    };

    # Allow running steam helpers from shell for testing purposes
    environment.systemPackages = [
      steam-run-url
      steam-launch-and-wait
    ];

    # Service for `steam-run-url`. This listens for Steam URLs from a named
    # pipe (typically at path `/run/user/1000/steam-run-url.fifo`) and then
    # launches Steam, passing the URL to it.
    # This workaround is necessary because Sunshine's security wrapper
    # prevents Steam from launching directly.
    home-manager.users.${cfg.user} = {
      systemd.user.services.steam-run-url-service = {
        Unit = {
          Description = "Listen and start Steam games by URL";
          PartOf = [ "default.target" ];
          Wants = [ "default.target" ];
          After = [ "default.target" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Restart = "on-failure";
          ExecStart = toString (
            pkgs.writers.writePython3 "steam-run-url-service" { } ''
              import os
              from pathlib import Path
              import subprocess

              pipe_path = Path(f'/run/user/{os.getuid()}/steam-run-url.fifo')
              try:
                  pipe_path.parent.mkdir(parents=True, exist_ok=True)
                  pipe_path.unlink(missing_ok=True)
                  os.mkfifo(pipe_path, 0o600)
                  steam_env = os.environ.copy()
                  steam_env["QT_QPA_PLATFORM"] = "wayland"
                  while True:
                      with pipe_path.open(encoding='utf-8') as pipe:
                          subprocess.Popen(['steam', pipe.read().strip()], env=steam_env)
              finally:
                  pipe_path.unlink(missing_ok=True)
            ''
          );
        };
      };
    };
  };
}
