#!/usr/bin/env bash
# Gaming VM Game Server Switcher
# This script helps manage which game server runs in the gaming VM

set -e

GAMING_VM="microvm@gaming"

show_status() {
    echo "=== Gaming VM Status ==="
    systemctl is-active "$GAMING_VM" && echo "Gaming VM: RUNNING" || echo "Gaming VM: STOPPED"
    echo ""
    echo "=== Game Server Status ==="
    if systemctl is-active "$GAMING_VM" &>/dev/null; then
        echo "Satisfactory: $(systemctl is-active satisfactory-server 2>/dev/null || echo 'STOPPED')"
        echo "Valheim: $(systemctl is-active valheimserver 2>/dev/null || echo 'STOPPED')"
    else
        echo "Gaming VM is not running"
    fi
}

start_satisfactory() {
    echo "Starting Satisfactory server..."
    
    # Stop Valheim if running
    if systemctl is-active valheimserver &>/dev/null; then
        echo "Stopping Valheim first..."
        systemctl stop valheimserver
    fi
    
    # Start gaming VM if not running
    if ! systemctl is-active "$GAMING_VM" &>/dev/null; then
        echo "Starting Gaming VM..."
        systemctl start "$GAMING_VM"
        sleep 5
    fi
    
    # Satisfactory auto-starts, but ensure it's running
    echo "Ensuring Satisfactory is running..."
    systemctl start satisfactory-server || true
    
    echo "Satisfactory should now be running!"
}

start_valheim() {
    echo "Starting Valheim server..."
    
    # Stop Satisfactory if running
    if systemctl is-active satisfactory-server &>/dev/null; then
        echo "Stopping Satisfactory first..."
        systemctl stop satisfactory-server
    fi
    
    # Start gaming VM if not running
    if ! systemctl is-active "$GAMING_VM" &>/dev/null; then
        echo "Starting Gaming VM..."
        systemctl start "$GAMING_VM"
        sleep 5
    fi
    
    echo "Starting Valheim..."
    systemctl start valheimserver
    
    echo "Valheim should now be running!"
}

stop_all() {
    echo "Stopping all game servers..."
    systemctl stop satisfactory-server 2>/dev/null || true
    systemctl stop valheimserver 2>/dev/null || true
    
    echo "Stopping Gaming VM..."
    systemctl stop "$GAMING_VM"
    
    echo "All game servers stopped."
}

show_help() {
    cat << EOF
Gaming Server Manager

Usage: $0 <command>

Commands:
    status          Show status of gaming VM and game servers
    satisfactory    Stop other games and start Satisfactory
    valheim         Stop other games and start Valheim
    stop            Stop all game servers and the gaming VM
    help            Show this help message

Examples:
    $0 status
    $0 satisfactory
    $0 valheim
    $0 stop

Note: This script should be run as root or with sudo.
EOF
}

# Main script logic
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    echo "Please run: sudo $0 $*"
    exit 1
fi

case "${1:-}" in
    status)
        show_status
        ;;
    satisfactory|satis)
        start_satisfactory
        echo ""
        show_status
        ;;
    valheim)
        start_valheim
        echo ""
        show_status
        ;;
    stop)
        stop_all
        echo ""
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '${1:-}'"
        echo ""
        show_help
        exit 1
        ;;
esac
