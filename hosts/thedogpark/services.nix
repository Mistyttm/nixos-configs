{ pkgs, ... }: {
  services = {
    gnome = {
      gnome-keyring = {
        enable = true;
      };
    };

    earlyoom = {
      enable = true;
    };

    pcscd = {
      enable = true;
    };

    resolved = {
      enable = true;
    };

    nginx = {
      enable = true;
    };
  };

  systemd.services.mistyttmpersonalsite = {
    description = "Build and run Vite for the MistyTTM Personal Site in production mode";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'cd /home/misty/Documents/mistyttmpersonalsite && ${pkgs.nodejs}/bin/npx vite --mode production --port 8080'";
      WorkingDirectory = "/home/misty/Documents/mistyttmpersonalsite";
      Restart = "on-failure";
      # AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      User = "misty";
      Group = "users";
      Environment = "PATH=${pkgs.nodejs}/bin:${pkgs.nodejs}/lib/node_modules/.bin:${pkgs.bash}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    };
  };

  systemd.services.valheimserver = {
    description = "Valheim Server";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];

    path = with pkgs; [ docker tmux ];

    # Set the command to run using ExecStart
    serviceConfig = {
      User = "root";
      Group = "root";
      ExecStart = ''
        ${pkgs.tmux}/bin/tmux new-session -d -s valheimserver && ${pkgs.tmux}/bin/tmux send-keys -t valheimserver 'cd /srv/valheim && ./docker_start_server.sh start_server.sh' Enter
      '';
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t valheimserver";
      Restart = "on-failure";
      RestartSec = "15s";
      WorkingDirectory = "/srv/valheim";
    };

    # Specify user and group if needed (default to root)
    wantedBy = [ "multi-user.target" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}