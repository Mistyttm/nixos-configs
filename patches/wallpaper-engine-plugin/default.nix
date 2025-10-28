final: prev: {
  kdePackages = prev.kdePackages // {
    wallpaper-engine-plugin = prev.kdePackages.wallpaper-engine-plugin.overrideAttrs (oldAttrs: {
      # Apply Qt 6.10 compatibility patch
      patches = (oldAttrs.patches or [ ]) ++ [
        ./qt-6.10-fix.patch
      ];

      # Add compiler flag to treat stringop-overflow as a warning instead of error
      # This is needed due to false positives in GCC 14.3.0 with the memcpy operations
      cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
        "-DCMAKE_CXX_FLAGS=-Wno-error=stringop-overflow"
      ];
    });
  };
}
