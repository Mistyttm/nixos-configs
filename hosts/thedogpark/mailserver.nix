{ config, ... } :{
  sops.secrets."mail-server-password-hash" = {
    sopsFile = ../../secrets/mail.yaml;
    owner = "virtualMail";
    group = "virtualMail";
  };

  mailserver = {
    enable = true;
    fqdn = "mail.mistyttm.dev";
    domains = [ "mistyttm.dev" ];
    # vmailGroupName = "vmail";
    loginAccounts = {
      "noreply@mistyttm.dev" = {
        hashedPasswordFile = config.sops.secrets."mail-server-password-hash".path;
      };
    };
    certificateScheme = "acme-nginx";
  };
}