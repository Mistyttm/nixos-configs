{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  writeText,
  kdePackages,
  # Attrset written to theme.conf.user, overriding values from theme.conf, e.g.
  #   pkgs.sddm-eucalyptus-drop.override { themeConfig.General.AccentColor = "#fb884f"; }
  themeConfig ? null,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sddm-eucalyptus-drop";
  version = "2.0.0";

  src = fetchFromGitLab {
    owner = "Matt.Jolly";
    repo = "sddm-eucalyptus-drop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wq6V3UOHteT6CsHyc7+KqclRMgyDXjajcQrX/y+rkA0=";
  };

  # Fixes Qt6 errors in v2.0.0 (session picker `Control` type mismatch,
  # undefined `Orientation`, KeyNavigation warning) and shows the user's
  # avatar in place of the generic user glyph.
  patches = [./qt6-fixes-and-avatar.patch];

  dontWrapQtApps = true;

  propagatedBuildInputs = with kdePackages; [
    qt5compat
    qtsvg
    qtvirtualkeyboard
  ];

  installPhase =
    ''
      runHook preInstall

      themeDir=$out/share/sddm/themes/${finalAttrs.passthru.themeName}
      mkdir -p $themeDir
      cp -r . $themeDir
    ''
    + lib.optionalString (themeConfig != null) ''
      ln -s ${
        # Quote every value like upstream's theme.conf: QSettings would
        # otherwise split unquoted values containing commas into lists.
        writeText "theme.conf.user" (lib.generators.toINI {
            mkKeyValue = k: v: ''${k}="${toString v}"'';
          }
          themeConfig)
      } $themeDir/theme.conf.user
    ''
    + ''
      runHook postInstall
    '';

  passthru.themeName = "eucalyptus-drop";

  meta = {
    description = "Eucalyptus Drop SDDM login theme, a Qt6 fork of Sugar Candy";
    homepage = "https://gitlab.com/Matt.Jolly/sddm-eucalyptus-drop";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [mistyttm];
  };
})
