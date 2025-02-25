{ config, lib, pkgs, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.misty = {
    isNormalUser = true;
    description = "Emmey Leo";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirt" "input" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
}
