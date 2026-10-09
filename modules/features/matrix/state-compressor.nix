{...}: {
  flake.nixosModules.matrix-state-compressor = {pkgs, ...}: {
    systemd.services.synapse-compress-state = {
      description = "Compress redundant Synapse state groups and reclaim Postgres space";
      after = ["postgresql.service"];
      requires = ["postgresql.service"];

      serviceConfig = {
        Type = "oneshot";
        User = "matrix-synapse";
        Group = "matrix-synapse";
        ExecStart = pkgs.writeShellScript "synapse-compress-state" ''
          set -euo pipefail

          echo "Running synapse_auto_compressor..."
          ${pkgs.rust-synapse-compress-state}/bin/synapse_auto_compressor \
            -p "user=matrix-synapse dbname=matrix-synapse host=/run/postgresql" \
            -c 500 \
            -n 100

          echo "Reclaiming disk space..."
          ${pkgs.postgresql_16}/bin/psql \
            "user=matrix-synapse dbname=matrix-synapse host=/run/postgresql" \
            -c "VACUUM (FULL, ANALYZE) state_groups_state;" \
            -c "VACUUM (FULL, ANALYZE) state_groups;"
        '';
      };
    };

    systemd.timers.synapse-compress-state = {
      description = "Weekly Synapse state compression";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "Sun 04:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
