# nix-topology configuration for Misty's infrastructure
# Build diagrams with: nix build .#topology.x86_64-linux.config.output
{ config, ... }:
let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkConnection
    mkDevice
    ;
in
{
  # ============================================================================
  # Networks
  # ============================================================================

  networks = {
    home = {
      name = "Home Network";
      cidrv4 = "192.168.1.0/24";
    };

    wireguard = {
      name = "WireGuard VPN";
      cidrv4 = "10.100.0.0/24";
    };
  };

  # ============================================================================
  # External Devices (not NixOS managed)
  # ============================================================================

  # Internet representation
  nodes.internet = mkInternet {
    connections = mkConnection "router" "wan";
  };

  # Home Router
  nodes.router = mkRouter "Home Router" {
    info = "Home Network Gateway";
    interfaceGroups = [
      [
        "lan1"
        "lan2"
        "lan3"
        "lan4"
      ]
      [ "wan" ]
    ];
    connections.lan1 = mkConnection "puppypc" "eth0";
    connections.lan2 = mkConnection "thekennel" "eth0";
    connections.lan3 = mkConnection "qnap" "eth0";
    interfaces.lan1 = {
      addresses = [ "192.168.1.1" ];
      network = "home";
    };
  };

  # QNAP NAS (for media storage)
  nodes.qnap = mkDevice "QNAP NAS" {
    info = "Media Storage (CIFS mount for *arr stack)";
    interfaceGroups = [ [ "eth0" ] ];
  };

  # Quest 2 VR Headset (connects to puppypc for PCVR)
  nodes.quest2 = mkDevice "Meta Quest 2" {
    info = "VR Headset (WiVRn streaming)";
    interfaceGroups = [ [ "wifi" ] ];
    connections.wifi = mkConnection "router" "lan4";
  };

  # ============================================================================
  # NixOS Host Customizations
  # ============================================================================

  # PuppyPC - Main Desktop (Gaming & VR Workstation)
  nodes.puppypc = {
    name = "PuppyPC";
    hardware.info = "AMD Ryzen 7 7800X3D, 32GB DDR5, RTX 3090";
    interfaces.eth0.network = "home";
    services.info = ''
      Gaming:
        • Steam, Lutris, Minecraft, Clone Hero, YARG
        • Dolphin Emulator, Heroic Launcher
        • Gamemode enabled
      VR:
        • WiVRn (Quest 2 wireless PCVR streaming)
        • SlimeVR (full-body tracking)
        • OpenComposite, Monado, wlx-overlay-s
      Streaming:
        • Sunshine (Moonlight host for thekennel)
      Virtualisation:
        • Waydroid, virt-manager
    '';
  };

  # mistylappytappy - Laptop
  nodes.mistylappytappy = {
    name = "MistyLappyTappy";
    hardware.info = "Gaming Laptop";
    interfaces.wlan0 = {
      network = "home";
      physicalConnections = [
        (mkConnection "router" "lan4")
      ];
    };
    services.info = ''
      Gaming:
        • Steam (portable mode)
        • Minecraft
        • Gamemode enabled
      Users:
        • misty
    '';
  };

  # thedogpark - VPS in Sydney
  nodes.thedogpark = {
    name = "TheDogPark";
    hardware.info = "Sydney VPS (Hardened Kernel)";
    interfaces = {
      eth0.physicalConnections = [
        (mkConnection "internet" "*")
      ];
      wg0 = {
        network = "wireguard";
        virtual = true;
        type = "wireguard";
        addresses = [ "10.100.0.1" ];
        physicalConnections = [
          (mkConnection "thekennel" "wg0")
        ];
        renderer.hidePhysicalConnections = true;
      };
    };
    services.info = ''
      Matrix:
        • Synapse (mistyttm.dev)
        • Coturn (TURN server)
        • Mautrix-Discord (bridge)
      Game Servers:
        • Minecraft (Fabric 1.21.4)
        • Valheim (Docker)
        • Satisfactory Dedicated Server
      Web:
        • Personal website (Vite)
        • Nginx reverse proxy
        • ACME/Let's Encrypt (Porkbun DNS)
      Security:
        • Fail2ban
        • Hardened Linux kernel
      Auto-upgrade enabled
    '';
  };

  # thekennel - Home Server
  nodes.thekennel = {
    name = "TheKennel";
    hardware.info = "Home Server (Nvidia GPU, Zen Kernel)";
    interfaces = {
      eth0.network = "home";
      wg0 = {
        network = "wireguard";
        virtual = true;
        type = "wireguard";
        addresses = [ "10.100.0.2" ];
      };
    };
    services.info = ''
      Media:
        • Jellyfin (transcoding)
        • Jellyseerr (requests)
        • Bazarr (subtitles)
      *arr Stack:
        • Radarr (movies)
        • Sonarr (TV shows)
        • Prowlarr (indexers)
        • qBittorrent (downloads)
        • Sabnzbd (usenet)
        • FlareSolverr (captcha)
      VPN:
        • Mullvad (for downloads)
        • WireGuard (to thedogpark)
      Streaming:
        • Moonlight client (from puppypc)
        • Auto-login streaming mode
      Nginx reverse proxy (internal)
    '';
  };
}
