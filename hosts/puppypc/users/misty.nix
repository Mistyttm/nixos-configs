{ config, lib, pkgs, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.misty = {
    isNormalUser = true;
    description = "Emmey Leo";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

#   accounts.email.accounts = {
#     misty = {
#       address = "emmey.leo@gmail.com";
#       flavor = "gmail.com";
#       realName = "Emmey Leo";
#     };
#   };
}
