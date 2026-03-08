# NixOS VM test for the Dispatcharr module (native / from-source)
#
# Run with:
#   nix build .#checks.x86_64-linux.dispatcharr
#   # or interactively:
#   nix build .#checks.x86_64-linux.dispatcharr.driverInteractive && ./result/bin/nixos-test-driver
{
  pkgs ? import <nixpkgs> { },
}:
let
  dispatcharr-frontend = pkgs.callPackage ../packages/dispatcharr-frontend.nix { };
  dispatcharr = pkgs.callPackage ../packages/dispatcharr.nix { inherit dispatcharr-frontend; };
in
pkgs.testers.nixosTest {
  name = "dispatcharr";

  meta.maintainers = [ ];

  nodes.machine =
    { ... }:
    {
      imports = [
        ../modules/nixos/dispatcharr.nix
      ];

      nixpkgs.overlays = [
        (_: _: { inherit dispatcharr dispatcharr-frontend; })
      ];

      # Enable Dispatcharr with test configuration
      services.dispatcharr = {
        enable = true;
        openFirewall = true;
        logLevel = "info";

        database = {
          type = "postgresql";
          createLocally = true;
        };

        redis.createLocally = true;
      };

      virtualisation = {
        cores = 2;
        memorySize = 2048;
        diskSize = 4096;
      };
    };

  testScript = ''
    machine.start()

    # Wait for backing services
    machine.wait_for_unit("postgresql.service")
    machine.wait_for_unit("redis-dispatcharr.service")

    # Wait for migrations to complete
    machine.wait_for_unit("dispatcharr-migrate.service", timeout=120)

    # Wait for the four application services
    machine.wait_for_unit("dispatcharr.service", timeout=60)
    machine.wait_for_unit("dispatcharr-daphne.service", timeout=30)
    machine.wait_for_unit("dispatcharr-celery.service", timeout=30)
    machine.wait_for_unit("dispatcharr-celerybeat.service", timeout=30)

    # Give gunicorn a moment to bind the socket
    machine.sleep(5)

    # Verify WebSocket endpoint via Daphne
    machine.wait_until_succeeds(
        "curl -sf -o /dev/null -w '%{http_code}' http://localhost:8001/ws/ | command grep -E '101|200|400|426'",
        timeout=30,
    )

    # Verify data directories were created
    machine.succeed("test -d /var/lib/dispatcharr")
    machine.succeed("test -d /var/lib/dispatcharr/logos")
    machine.succeed("test -d /var/lib/dispatcharr/plugins")

    # Verify the dispatcharr user exists
    machine.succeed("id dispatcharr")

    # Verify the gunicorn socket exists
    machine.succeed("test -S /run/dispatcharr/dispatcharr.sock")

    # Verify the websocket firewall port is open
    machine.succeed("ss -tlnp | command grep 8001")
  '';
}
