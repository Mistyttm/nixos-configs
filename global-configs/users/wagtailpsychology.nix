{ pkgs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wagtailpsychology = {
    isNormalUser = true;
    description = "Emmey Leo Work Account";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirt"
      "input"
      "scanner"
      "lp"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
