{ ... }:
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
      # Add your local network range here
    ];

    jails = {
      # Protect SSH
      sshd = {
        enabled = true;
        port = "22"; # Change if you use a different SSH port
      };
    };
  };
}
