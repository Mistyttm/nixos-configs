{
  pkgs,
  ...
}:
{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
  ];

  environment.systemPackages =
    with pkgs.kdePackages;
    [
      plasma-browser-integration
      kio
      kio-fuse
      kio-extras
      kio-gdrive
      kaccounts-integration
      kaccounts-providers
      signond
      accounts-qt
      signon-kwallet-extension
      kalk
      skanpage
      filelight
      # wallpaper-engine-plugin
    ]
    ++ [
      pkgs.darkly
    ];

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        _kdeFinal: kdePrev: {
          # https://old.reddit.com/r/NixOS/comments/1pdtc3v/kde_plasma_is_slow_compared_to_any_other_distro/
          # https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3194531220
          plasma-workspace =
            let
              # the package we want to override
              basePkg = kdePrev.plasma-workspace;
              # a helper package that merges all the XDG_DATA_DIRS into a single directory
              xdgdataPkg = final.stdenv.mkDerivation {
                name = "${basePkg.name}-xdgdata";
                buildInputs = [ basePkg ];
                dontUnpack = true;
                dontFixup = true;
                dontWrapQtApps = true;
                installPhase = ''
                  mkdir -p $out/share
                  ( IFS=:
                    for DIR in $XDG_DATA_DIRS; do
                      if [[ -d "$DIR" ]]; then
                        ${prev.lib.getExe prev.lndir} -silent "$DIR" $out
                      fi
                    done
                  )
                '';
              };
              # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
              # script and instead inject the path of the above helper package
              derivedPkg = basePkg.overrideAttrs {
                preFixup = ''
                  for index in "''${!qtWrapperArgs[@]}"; do
                    if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                      unset -v "qtWrapperArgs[$((index+0))]"
                      unset -v "qtWrapperArgs[$((index+1))]"
                      unset -v "qtWrapperArgs[$((index+2))]"
                      unset -v "qtWrapperArgs[$((index+3))]"
                    fi
                  done
                  qtWrapperArgs=("''${qtWrapperArgs[@]}")
                  qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                  qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
                '';
              };
            in
            derivedPkg;
        }
      );
    })
  ];
}
