{self, ...}: {
  flake.nixosModules.puppypcHomeManager = {config, ...}: {
    imports = [
      self.nixosModules.homeManager
    ];

    home-manager.users.misty = {
      imports = with self.homeModules; [
        misty
        git
        gpg
        xdg
        vscode
        zed
        easyeffects
        gui-packages
        eza
        bat
        fastfetch
        ripgrep
        starship
        zsh
        kitty
        direnv
        gameModding
        mangohud
        # linux-wallpaperengine
        protonmail
        protonDrive
        plasma
      ];

      gpg = {
        enable = true;
        publicKeySource = ./PuppyPC.asc;
      };

      programs.puppy = {
        protonDrive = {
          enable = true;
          usernameFile = config.sops.secrets.protondrive_username.path;
          passwordFile = config.sops.secrets.protondrive_password.path;
          otpSecretKeyFile =
            if config.doggate.protonDrive.totp
            then config.sops.secrets.protondrive_otp_secret_key.path
            else null;
        };
        starship.hostname = config.networking.hostName;
        git = {
          enable = true;
          signingKey = "5D6050A7E4497C4A";
        };
      };
    };
  };
}
