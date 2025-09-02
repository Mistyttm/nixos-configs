{
  pkgs,
  ...
}:
let
trickleOverlay = (pkgs.trickle.overrideAttrs (oldAttrs: {
      preConfigure = ''
        sed -i 's|libevent.a|libevent.so|' configure
        sed -i 's/if test "$HAVEMETHOD" = "no"; then/if false; then/' configure
        sed -i 's/exit(1)/exit(0)/' configure
        sed -i '1i#define DLOPENLIBC "${pkgs.stdenv.cc.libc}/lib/libc.so.6"' trickle-overload.c
      '';
      env = (oldAttrs.env or {}) // {
        NIX_CFLAGS_COMPILE = toString ([
          "-I${pkgs.libtirpc.dev}/include/tirpc"
          "-Wno-pointer-sign"
        ]);
      };
      patches = (oldAttrs.patches or []) ++ [
        ../../patches/trickle/fix-build-failure.patch
      ];
    }));
in {
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #     qemu
    sddm-sugar-dark
    libaccounts-glib
    nil
    bitwarden-desktop
    bitwarden-cli
    trickleOverlay
  ];

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;

  environment.etc."trickled.conf".text = ''
    [vesktop]
    Priority = 1
    Time-Smoothing = 0.1
    Length-Smoothing = 2
    Upload = 2500
    Download = 0
  '';

  systemd.services.trickled = {
    description = "Trickle bandwidth limiter daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      # Run in foreground mode, let systemd handle daemonization
      ExecStart = "${trickleOverlay}/bin/trickled -f -c /etc/trickled.conf";
      Type = "simple";  # Changed from "forking" to "simple"
      # Removed PIDFile since we're using Type=simple
      Restart = "on-failure";
      RestartSec = "5s";
      # Create runtime directory for any files trickled might need
      RuntimeDirectory = "trickled";
      RuntimeDirectoryMode = "0755";
    };
  };
}
