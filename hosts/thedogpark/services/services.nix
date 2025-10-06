{ pkgs, ... }:
{
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

    path = with pkgs; [
      docker
      tmux
    ];

    # Set the command to run using ExecStart
    serviceConfig = {
      User = "root";
      Group = "root";
      WorkingDirectory = "/srv/valheim";
      ExecStart = ''
        /srv/valheim/start.sh
      '';
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t valheimserver";
      Restart = "on-failure";
      RestartSec = "15s";
    };

    # Specify user and group if needed (default to root)
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.satisfactory-server = {
    description = "Satisfactory Dedicated Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "steam";
      Group = "steam";
      WorkingDirectory = "/var/lib/steamuser/SatisfactoryDedicatedServer";
      ExecStart = "/var/lib/steamuser/SatisfactoryDedicatedServer/FactoryServer.sh";
      Restart = "on-failure";
      RestartSec = "10s";
      
      # Security settings
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/steamuser" ];
      
      # Resource limits
      LimitNOFILE = 65536;
      
      # Environment
      Environment = [
        "HOME=/var/lib/steamuser"
        "USER=steam"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
