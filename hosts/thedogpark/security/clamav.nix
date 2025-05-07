{ pkgs }: {
  environment.systemPackages = with pkgs; [
    clamav
    clamtk
  ];

  services.clamav = {
    enable = true;
    daemon = {
      enable = true;
      config = {
        "LocalSocket" = "/var/run/clamav/clamd.sock";
        "TCPSocket" = 3310;
      };
    };
    scanner = {
      enable = true;
    };
    updater = {
      enable = true;
      config = {
        "DatabaseDirectory" = "/var/lib/clamav";
        "LocalSocket" = "/var/run/clamav/clamd.sock";
        "TCPSocket" = 3310;
      };
    };
  };
}