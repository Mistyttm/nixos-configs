{ ... }:

{
  imports = [
    ../../../../global-configs/programs/gpg.nix
  ];

  gpg = {
    enable = true;
    publicKeySource = ./me/PuppyPC.asc;
  };
}
