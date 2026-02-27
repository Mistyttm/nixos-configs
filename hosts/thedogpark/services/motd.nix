{ ... }:
{
  environment.etc."profile.d/server-stats.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh

      # Only run for interactive SSH sessions
      [ -z "$PS1" ] && return

      RESET='\033[0m'
      BOLD='\033[1m'
      CYAN='\033[0;36m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      RED='\033[0;31m'
      DIM='\033[2m'

      BAR_WIDTH=20

      _bar() {
        pct=$1
        filled=$(( pct * BAR_WIDTH / 100 ))
        empty=$(( BAR_WIDTH - filled ))
        if [ "$pct" -ge 90 ]; then colour="$RED"
        elif [ "$pct" -ge 70 ]; then colour="$YELLOW"
        else colour="$GREEN"
        fi
        printf "%s[" "$colour"
        i=0; while [ $i -lt $filled ]; do printf "█"; i=$(( i + 1 )); done
        i=0; while [ $i -lt $empty ];  do printf "░"; i=$(( i + 1 )); done
        printf "]%s %d%%" "$RESET" "$pct"
      }

      HOSTNAME=$(hostname)
      UPTIME=$(uptime -p 2>/dev/null | sed 's/up //')
      LOAD=$(uptime | awk -F'load average:' '{gsub(/ /,"",$2); print $2}')
      LOAD1=$(echo "$LOAD"  | cut -d',' -f1)
      LOAD5=$(echo "$LOAD"  | cut -d',' -f2)
      LOAD15=$(echo "$LOAD" | cut -d',' -f3)

      CPU_IDLE=$(top -bn1 2>/dev/null | awk '/^%Cpu/ {print $8}' | cut -d'.' -f1)
      CPU_PCT=$(( 100 - CPU_IDLE ))

      RAM_TOTAL_KB=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
      RAM_AVAIL_KB=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
      RAM_USED_KB=$(( RAM_TOTAL_KB - RAM_AVAIL_KB ))
      RAM_PCT=$(( RAM_USED_KB * 100 / RAM_TOTAL_KB ))
      RAM_USED=$(awk "BEGIN {printf \"%.1f\", $RAM_USED_KB/1048576}")
      RAM_TOTAL=$(awk "BEGIN {printf \"%.1f\", $RAM_TOTAL_KB/1048576}")

      DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
      DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
      DISK_PCT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

      VAR_USED=$(df -h /var 2>/dev/null | awk 'NR==2 {print $3}')
      VAR_TOTAL=$(df -h /var 2>/dev/null | awk 'NR==2 {print $2}')
      VAR_PCT=$(df /var 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

      SVC_ACTIVE=$(systemctl list-units --type=service --state=active --no-legend 2>/dev/null | wc -l)
      SVC_FAILED=$(systemctl --failed --no-legend 2>/dev/null | grep -c '●' || echo 0)

      IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1); exit}')

      echo ""
      printf "''${BOLD}''${CYAN}  ╔══════════════════════════════════════════════╗''${RESET}\n"
      printf "''${BOLD}''${CYAN}  ║  🐕  %-38s  ║''${RESET}\n" "$HOSTNAME"
      printf "''${BOLD}''${CYAN}  ╚══════════════════════════════════════════════╝''${RESET}\n"
      echo ""
      printf "  ''${BOLD}%-10s''${RESET} %s\n"  "Uptime"   "$UPTIME"
      printf "  ''${BOLD}%-10s''${RESET} %s / %s / %s  ''${DIM}(1m / 5m / 15m)''${RESET}\n" "Load" "$LOAD1" "$LOAD5" "$LOAD15"
      printf "  ''${BOLD}%-10s''${RESET} "       "CPU"; _bar "$CPU_PCT"; echo ""
      printf "  ''${BOLD}%-10s''${RESET} "       "RAM"; _bar "$RAM_PCT"; printf "  ''${DIM}%s / %s GiB''${RESET}\n" "$RAM_USED" "$RAM_TOTAL"
      printf "  ''${BOLD}%-10s''${RESET} "       "Disk /"; _bar "$DISK_PCT"; printf "  ''${DIM}%s / %s''${RESET}\n" "$DISK_USED" "$DISK_TOTAL"
      if [ -n "$VAR_PCT" ]; then
        printf "  ''${BOLD}%-10s''${RESET} "     "Disk /var"; _bar "$VAR_PCT"; printf "  ''${DIM}%s / %s''${RESET}\n" "$VAR_USED" "$VAR_TOTAL"
      fi
      printf "  ''${BOLD}%-10s''${RESET} %s\n"  "IP"       "$IP"
      printf "  ''${BOLD}%-10s''${RESET} ''${GREEN}%s active''${RESET}" "Services" "$SVC_ACTIVE"
      if [ "$SVC_FAILED" -gt 0 ] 2>/dev/null; then
        printf ", ''${RED}%s failed''${RESET}" "$SVC_FAILED"
      fi
      echo ""
      echo ""
    '';
  };
}
