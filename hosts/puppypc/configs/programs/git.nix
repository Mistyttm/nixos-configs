{ config, pkgs, ... }: {
  programs.git = {
    signing = {
      key = "A1B4238FBD53F150";
      signByDefault = true;
    };
#     includes.*.contents = {
#       commit = {
#         gpgSign = true;
#       };
#     };
  };
}
