{ ... }:
{
  environment.interactiveShellInit = ''
    # Only run on first shell level (not subshells)
    [ "$SHLVL" -ne 1 ] && return || true

    RESET=$(printf '\033[0m')
    BOLD=$(printf '\033[1m')
    CYAN=$(printf '\033[0;36m')
    GREEN=$(printf '\033[0;32m')
    YELLOW=$(printf '\033[1;33m')
    RED=$(printf '\033[0;31m')
    DIM=$(printf '\033[2m')

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
    [ -z "$UPTIME" ] && UPTIME=$(uptime 2>/dev/null | sed 's/.*up \([^,]*\).*/\1/' | xargs)
    LOAD=$(uptime | awk -F'load average:' '{gsub(/ /,"",$2); print $2}')
    LOAD1=$(echo "$LOAD"  | cut -d',' -f1)
    LOAD5=$(echo "$LOAD"  | cut -d',' -f2)
    LOAD15=$(echo "$LOAD" | cut -d',' -f3)

    CPU_IDLE=$(top -bn1 2>/dev/null | awk '/^%Cpu/ {print $8}' | cut -d'.' -f1)
    CPU_PCT=$(( 100 - CPU_IDLE ))

    RAM_TOTAL_KB=$(awk '/^MemTotal:/     {print $2}' /proc/meminfo)
    RAM_AVAIL_KB=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
    RAM_USED_KB=$(( RAM_TOTAL_KB - RAM_AVAIL_KB ))
    RAM_PCT=$(( RAM_USED_KB * 100 / RAM_TOTAL_KB ))
    RAM_USED=$(awk "BEGIN {printf \"%.1f\", $RAM_USED_KB/1048576}")
    RAM_TOTAL=$(awk "BEGIN {printf \"%.1f\", $RAM_TOTAL_KB/1048576}")

    DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
    DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
    DISK_PCT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    ROOT_DEV=$(df / | awk 'NR==2 {print $1}')
    VAR_DEV=$(df /var 2>/dev/null | awk 'NR==2 {print $1}')
    if [ -n "$VAR_DEV" ] && [ "$VAR_DEV" != "$ROOT_DEV" ]; then
      VAR_USED=$(df -h /var | awk 'NR==2 {print $3}')
      VAR_TOTAL=$(df -h /var | awk 'NR==2 {print $2}')
      VAR_PCT=$(df /var | awk 'NR==2 {print $5}' | tr -d '%')
    fi

    SVC_ACTIVE=$(systemctl list-units --type=service --state=active --no-legend 2>/dev/null | wc -l)
    SVC_FAILED=$(systemctl --failed --no-legend 2>/dev/null | grep -c '●' || echo 0)

    IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1); exit}')

    echo ""
    printf "%s%s  ╔══════════════════════════════════════════════╗%s\n" "$BOLD" "$CYAN" "$RESET"
    printf "%s%s  ║  🐕  %-38s  ║%s\n" "$BOLD" "$CYAN" "$HOSTNAME" "$RESET"
    printf "%s%s  ╚══════════════════════════════════════════════╝%s\n" "$BOLD" "$CYAN" "$RESET"
    echo ""
    printf "  %s%-10s%s %s\n"              "$BOLD" "Uptime"    "$RESET" "$UPTIME"
    printf "  %s%-10s%s %s / %s / %s  %s(1m / 5m / 15m)%s\n" "$BOLD" "Load" "$RESET" "$LOAD1" "$LOAD5" "$LOAD15" "$DIM" "$RESET"
    printf "  %s%-10s%s " "$BOLD" "CPU" "$RESET";     _bar "$CPU_PCT"; echo ""
    printf "  %s%-10s%s " "$BOLD" "RAM" "$RESET";     _bar "$RAM_PCT"; printf "  %s%s / %s GiB%s\n" "$DIM" "$RAM_USED" "$RAM_TOTAL" "$RESET"
    printf "  %s%-10s%s " "$BOLD" "Disk /" "$RESET";  _bar "$DISK_PCT"; printf "  %s%s / %s%s\n" "$DIM" "$DISK_USED" "$DISK_TOTAL" "$RESET"
    if [ -n "$VAR_PCT" ]; then
      printf "  %s%-10s%s " "$BOLD" "Disk /var" "$RESET"; _bar "$VAR_PCT"; printf "  %s%s / %s%s\n" "$DIM" "$VAR_USED" "$VAR_TOTAL" "$RESET"
    fi
    printf "  %s%-10s%s %s\n"              "$BOLD" "IP"        "$RESET" "$IP"
    printf "  %s%-10s%s %s%s active%s"     "$BOLD" "Services"  "$RESET" "$GREEN" "$SVC_ACTIVE" "$RESET"
    if [ "$SVC_FAILED" -gt 0 ] 2>/dev/null; then
      printf ", %s%s failed%s" "$RED" "$SVC_FAILED" "$RESET"
    fi
    echo ""
    echo ""
  '';
}
