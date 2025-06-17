{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  pname = "kde-dolphin-open-vscode";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Merrit";
    repo = "kde-dolphin-open-vscode";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  preInstall = ''
    mkdir -p $out/share/kio/servicemenus
  '';

  installPhase = ''
    cp openVSCode.desktop $out/share/kio/servicemenus/
    chmod +x $out/share/kio/servicemenus/openVSCode.desktop
  '';

  meta = {
    description = "Dolphin service menu to open files/folders in Visual Studio Code";
    homepage = "https://github.com/Merrit/kde-dolphin-open-vscode";
  };
})
