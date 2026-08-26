{self, ...}: {
  flake.nixosModules.matrix-notify = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.matrix-notify;
  in {
    options.services.matrix-notify = {
      enable = lib.mkEnableOption "direct Matrix notifications for non-Prometheus events";
      roomId = lib.mkOption {
        type = lib.types.str;
        description = "Matrix room ID to post into (starts with '!').";
      };
      watchedUnits = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "systemd units that should notify on failure.";
      };
    };

    config = lib.mkIf cfg.enable {
      sops.secrets."matrix-notify-token" = {
        sopsFile = self.secrets.matrix-alertmanager;
        key = "token"; # reuses the same bot user's token, no 2nd account
      };

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "matrix-notify" ''
          set -euo pipefail
          MESSAGE="''${1:?usage: matrix-notify <message>}"
          TOKEN="$(cat ${config.sops.secrets."matrix-notify-token".path})"
          TXN="$(date +%s%N)"
          BODY=$(${pkgs.jq}/bin/jq -nc --arg body "$MESSAGE" '{msgtype: "m.text", body: $body}')
          ${pkgs.curl}/bin/curl -sf -X PUT \
            "https://mistyttm.dev/_matrix/client/v3/rooms/${cfg.roomId}/send/m.room.message/$TXN" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$BODY"
        '')
      ];

      systemd.services =
        {
          "matrix-notify@" = {
            description = "Notify Matrix that %i failed";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.writeShellScript "matrix-notify-unit-failure" ''
                /run/current-system/sw/bin/matrix-notify "⚠️ %i failed on $(hostname)"
              ''}";
            };
          };
        }
        // lib.genAttrs cfg.watchedUnits (_: {onFailure = ["matrix-notify@%n.service"];});
    };
  };
}
