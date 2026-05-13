{ inputs, self, ... }:
{
  flake.homeModules.fastfetch =
    { pkgs, lib, ... }:
    {
      programs.fastfetch = {
        enable = true;
        package = pkgs.fastfetch;
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.fastfetch = inputs.wrapper-modules.wrappers.fastfetch.wrap {
        inherit pkgs;
        package = pkgs.fastfetch;

        settings = {
          logo = {
            source = "~/Pictures/paw-print.png";
            width = 28;
            padding = {
              top = 2;
              left = 1;
              right = 2;
            };
          };
          display = {
            separator = "  ";
          };
          modules = [
            # Title
            {
              type = "title";
              format = "{#1}╭───────────── {#}{user-name-colored}@{host-name-colored}";
            }
            # System Information
            {
              type = "custom";
              format = "{#1}│ {#}System Information";
            }
            {
              type = "os";
              key = "{#separator}│  {#keys}󰍹 OS";
            }
            {
              type = "kernel";
              key = "{#separator}│  {#keys}󰒋 Kernel";
            }
            {
              type = "uptime";
              key = "{#separator}│  {#keys}󰅐 Uptime";
            }
            {
              type = "packages";
              key = "{#separator}│  {#keys}󰏖 Packages";
              format = "{all}";
            }
            {
              type = "custom";
              format = "{#1}│";
            }
            # Desktop Environment
            {
              type = "custom";
              format = "{#1}│ {#}Desktop Environment";
            }
            {
              type = "de";
              key = "{#separator}│  {#keys}󰧨 DE";
            }
            {
              type = "wm";
              key = "{#separator}│  {#keys}󱂬 WM";
            }
            {
              type = "wmtheme";
              key = "{#separator}│  {#keys}󰉼 Theme";
            }
            {
              type = "display";
              key = "{#separator}│  {#keys}󰹑 Resolution";
            }
            {
              type = "shell";
              key = "{#separator}│  {#keys}󰞷 Shell";
            }
            {
              type = "terminalfont";
              key = "{#separator}│  {#keys}󰛖 Font";
            }
            {
              type = "custom";
              format = "{#1}│";
            }
            # Hardware Information
            {
              type = "custom";
              format = "{#1}│ {#}Hardware Information";
            }
            {
              type = "cpu";
              temp = true;
              key = "{#separator}│  {#keys}󰻠 CPU";
            }
            {
              type = "gpu";
              temp = true;
              key = "{#separator}│  {#keys}󰢮 GPU";
            }
            {
              type = "memory";
              key = "{#separator}│  {#keys}󰍛 Memory";
            }
            {
              type = "board";
              key = "{#separator}│  {#keys} Motherboard";
            }
            {
              type = "disk";
              key = "{#separator}│  {#keys}󰋊 Disk (/)";
              folders = "/";
            }
            {
              type = "disk";
              key = "{#separator}│  {#keys}󰋊 Disk (/mnt/misty/games)";
              folders = "/mnt/misty/games";
            }
            {
              type = "custom";
              format = "{#1}│";
            }
            # General Information
            {
              type = "custom";
              format = "{#1}│  {#}General Information";
            }
            {
              type = "weather";
              timeout = 1000;
              key = "{#separator}│  {#keys}󰖕 Weather";
            }
            {
              type = "datetime";
              key = "{#separator}│  {#keys} Date & Time";
            }
            {
              type = "localip";
              showIpv6 = false;
              showMac = false;
              showSpeed = true;
              showMtu = false;
              showLoop = false;
              showFlags = false;
              showAllIps = false;
              key = "{#separator}│  {#keys}󰩠 Local IP";
            }
            {
              type = "custom";
              format = "{#1}│";
            }
            # Colours
            {
              type = "colors";
              key = "{#separator}│";
              symbol = "circle";
            }
            # Footer
            {
              type = "custom";
              format = "{#1}╰───────────────────────────────╯";
            }
          ];
        };
      };
    };
}
