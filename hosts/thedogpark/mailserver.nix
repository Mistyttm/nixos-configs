{ config, ... } :{
  sops.secrets."mail-server-password-hash" = {
    sopsFile = ../../secrets/mail.yaml;
    owner = config.users.users.vmail.name;
    group = config.users.users.vmail.group;
  };

  mailserver = {
    enable = true;
    fqdn = "mail.mmistyttmm.dev";
    domains = [ "mistyttm.dev" ];

    loginAccounts = {
      "noreply@mistyttm.dev" = {
        hashedPasswordFile = config.sops.secrets."mail-server-password-hash".path;
      };
    };
    certificateScheme = "acme-nginx";
  };
}