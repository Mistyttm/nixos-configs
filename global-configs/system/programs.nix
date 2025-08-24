{
  pkgs,
  ...
}:
{
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
    (trickle.overrideAttrs (oldAttrs: {
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
    }))
  ];

  programs.zsh.enable = true;
  users.users.misty.shell = pkgs.zsh;
}
