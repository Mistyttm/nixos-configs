{ config, lib, pkgs, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.misty = {
    isNormalUser = true;
    description = "Emmey Leo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
}
