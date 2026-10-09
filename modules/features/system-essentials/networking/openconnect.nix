{...}: {
  flake.nixosModules.openconnect = {pkgs, ...}: {
    networking = {
      networkmanager = {
        plugins = with pkgs; [
          networkmanager-openconnect
        ];
      };

      openconnect.interfaces.uq = {
        gateway = "vpn.uq.edu.au";
        protocol = "anyconnect";

        extraOptions = {
          useragent = "AnyConnect-compatible OpenConnect VPN agent";
          reported-os = "windows";
        };

        autoStart = false;
      };
    };
  };
}
