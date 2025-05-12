{ stdenv, fetchFromGitHub }:
{
  sddm-sugar-dark = stdenv.mkDerivation rec {
    pname = "sddm-sugar-candy-theme";
    version = "1.2";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sugar-dark
    '';
    src = fetchFromGitHub {
      owner = "Kangie";
      repo = "sddm-sugar-candy";
      rev = "v${version}";
      #   sha256 = "0gx0am7vq1ywaw2rm1p015x90b75ccqxnb1sz3wy8yjl27v82yhb";
    };
  };
}
