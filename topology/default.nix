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
    hardware.info = ''
      AMD Ryzen 7 7800X3D, 32GB DDR5, RTX 3090
      Gaming: Steam, Lutris, Minecraft, Clone Hero, YARG, Dolphin, Heroic
      VR: WiVRn (Quest 2), SlimeVR, OpenComposite, Monado, wlx-overlay-s
      Streaming: Sunshine (Moonlight host)
      Virtualisation: Waydroid, virt-manager
    '';
    interfaces.eth0.network = "home";
  };

  # mistylappytappy - Laptop
  nodes.mistylappytappy = {
    name = "MistyLappyTappy";
    hardware.info = ''
      Gaming Laptop
      Gaming: Steam (portable), Minecraft, Gamemode
      Users: misty, wagtailpsychology
    '';
    interfaces.wlan0 = {
      network = "home";
      physicalConnections = [
        (mkConnection "router" "lan4")
      ];
    };
  };

  # thedogpark - VPS in Sydney
  nodes.thedogpark = {
    name = "TheDogPark";
    hardware.info = ''
      Sydney VPS (Hardened Kernel)
      Matrix: Synapse, Coturn, Mautrix-Discord
      Game Servers: Minecraft, Valheim, Satisfactory
      Web: Personal site, Nginx, ACME/Porkbun
      Security: Fail2ban, Auto-upgrade
    '';
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
  };

  # thekennel - Home Server
  nodes.thekennel = {
    name = "TheKennel";
    hardware.info = ''
      Home Server (Nvidia GPU, Zen Kernel)
      Media: Jellyfin, Jellyseerr, Bazarr
      *arr: Radarr, Sonarr, Prowlarr, qBittorrent, Sabnzbd, FlareSolverr
      VPN: Mullvad, WireGuard to thedogpark
      Streaming: Moonlight client from puppypc
      Nginx reverse proxy
    '';
    interfaces = {
      eth0.network = "home";
      wg0 = {
        network = "wireguard";
        virtual = true;
        type = "wireguard";
        addresses = [ "10.100.0.2" ];
      };
    };
  };
}
