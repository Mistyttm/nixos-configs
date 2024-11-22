{ ... }:

{
  nix = {
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
