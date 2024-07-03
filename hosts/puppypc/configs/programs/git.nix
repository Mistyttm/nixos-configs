{ config, pkgs, ... }: {
  programs.git = {
    signing = {
      key = "A1B4238FBD53F150";
      gpgPath = "\${pkgs.gnupg}/bin/gpg2";
      signByDefault = true;
    };
    includes.*.contents = {
      commit = {
        gpgSign = true;
      };
    };
  };
}
