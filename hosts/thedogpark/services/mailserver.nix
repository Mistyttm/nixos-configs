{ config, ... } :{
  sops.secrets."mail-server-password-hash" = {
    sopsFile = ../../../secrets/mail.yaml;
    owner = "virtualMail";
    group = "virtualMail";
  };

  mailserver = {
    enable = true;
    fqdn = "mail.mistyttm.dev";
    domains = [ "mistyttm.dev" ];
    forwards = {
      "contact@mistyttm.dev" = "emmey.leo@gmail.com";
      "junk@mistyttm.dev" = "emmey.leo@gmail.com";
      "school@mistyttm.dev" = "emmey.leo@connect.qut.edu.au";
      "personal@mistyttm.dev" = "emmey.leo@gmail.com";
      "secondary@mistyttm.dev" = "elijah.r.leo@gmail.com";
    };
    # vmailGroupName = "vmail";
    loginAccounts = {
      "noreply@mistyttm.dev" = {
        hashedPasswordFile = config.sops.secrets."mail-server-password-hash".path;
      };
    };
    certificateScheme = "acme-nginx";
  };
}