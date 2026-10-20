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
        plasmaManager
      ];

      # Dock on the second monitor as well as the primary.
      programs.puppy.plasma.dockScreens = [
        0
        1
      ];

      services.easyeffects.settings = {
        StreamInputs.inputDevice = "alsa_input.usb-Razer_Inc_Razer_Seiren_Mini_UC2222L03203690-00.pro-input-0";
      };

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
