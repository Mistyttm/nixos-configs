{ config, ... }:
{
  services.sabnzbd = {
    enable = true;
    group = "media";
    openFirewall = true;

    # Allow SABnzbd to write to its config file (fixes "Cannot write to INI" error)
    # This creates a writable copy of the config at runtime.
    allowConfigWrite = true;

    # Use declarative settings instead of manual file patching
    secretFiles = [ config.sops.templates."sabnzbd-secrets.ini".path ];

    settings = {
      misc = {
        config_conversion_version = 4;
        language = "en";
        host = "0.0.0.0";
        port = 8085;
        cache_limit = "1G";
        web_dir = "Glitter";
        web_color = "Auto";
        enable_https = false;
        inet_exposure = 0;
        download_dir = "Downloads/incomplete";
        complete_dir = "Downloads/complete";

        # User defined settings
        max_art_tries = 3;
        top_only = 0;
        sfv_check = 1;
        script_can_fail = 0;
        enable_recursive = 1;
        flat_unpack = 0;
        par_option = "";
        pre_check = 0;
        fail_hopeless_jobs = 1;
        fast_fail = 1;
        auto_disconnect = 1;
        no_dupes = 0;
        no_series_dupes = 0;
        no_smart_dupes = 0;
        dupes_propercheck = 1;
        pause_on_pwrar = 1;
        ignore_samples = 0;
        deobfuscate_final_filenames = 1;
        auto_sort = "";
        direct_unpack = 1;
        propagation_delay = 0;
        folder_rename = 1;
        replace_spaces = 0;
        replace_underscores = 0;
        replace_dots = 0;
        safe_postproc = 1;
        pause_on_post_processing = 0;
        enable_all_par = 0;
        sanitize_safe = 0;
        new_nzb_on_failure = 0;
        history_retention_option = "all";
        history_retention_number = 1;
        quota_period = "m";
        enable_tv_sorting = 0;
        tv_categories = "tv,";
        enable_movie_sorting = 0;
        movie_categories = "movies,";
        enable_date_sorting = 0;
        date_categories = "tv,";
        chk_rss_updated = 0;
        rss_rate = 60;
        enable_par_cleanup = 1;
        process_unpacked_par2 = 1;
        enable_unrar = 1;
        enable_7zip = 1;
        enable_filejoin = 1;
        enable_tsjoin = 1;
        overwrite_files = 0;
        ignore_unrar_dates = 0;
        max_url_retries = 10;
        permissions = 755;

        # Whitelist
        host_whitelist = "thekennel, localhost, 127.0.0.1";
      };

      logging = {
        log_level = 1;
        max_log_size = 5242880;
        log_backups = 5;
      };

      servers = {
        "aunews.frugalusenet.com" = {
          name = "aunews.frugalusenet.com";
          displayname = "aunews.frugalusenet.com";
          host = "aunews.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          # Password moved to sops-nix
          connections = 190;
          ssl = true;
          ssl_verify = 2;
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "";
          quota = "";
          usage_at_start = 0;
          priority = 0;
          notes = "";
        };
        "eunews.frugalusenet.com" = {
          name = "eunews.frugalusenet.com";
          displayname = "eunews.frugalusenet.com";
          host = "eunews.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          # Password moved to sops-nix
          connections = 90;
          ssl = true;
          ssl_verify = 3;
          ssl_ciphers = "";
          enable = true;
          required = false;
          optional = false;
          retention = 0;
          expire_date = "";
          quota = "";
          usage_at_start = 0;
          priority = 1;
          notes = "";
        };
        "news.frugalusenet.com" = {
          name = "news.frugalusenet.com";
          displayname = "news.frugalusenet.com";
          host = "news.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 90;
          ssl = true;
          ssl_verify = 2;
          enable = true;
          required = false;
          optional = false;
          priority = 1;
        };
        "newswest.frugalusenet.com" = {
          name = "newswest.frugalusenet.com";
          displayname = "newswest.frugalusenet.com";
          host = "newswest.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 90;
          ssl = true;
          ssl_verify = 2;
          enable = true;
          required = false;
          optional = false;
          priority = 1;
        };
        "sanews.frugalusenet.com" = {
          name = "sanews.frugalusenet.com";
          displayname = "sanews.frugalusenet.com";
          host = "sanews.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 190;
          ssl = true;
          ssl_verify = 2;
          enable = true;
          required = false;
          optional = false;
          priority = 1;
        };
        "asnews.frugalusenet.com" = {
          name = "asnews.frugalusenet.com";
          displayname = "asnews.frugalusenet.com";
          host = "asnews.frugalusenet.com";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 190;
          ssl = true;
          ssl_verify = 2;
          enable = true;
          required = false;
          optional = false;
          priority = 1;
        };
        "usnews.blocknews.net" = {
          name = "usnews.blocknews.net";
          displayname = "usnews.blocknews.net";
          host = "usnews.blocknews.net";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 20;
          ssl = true;
          ssl_verify = 2;
          enable = false;
          required = false;
          optional = true;
          priority = 2;
        };
        "bonus.frugalusenet.net" = {
          name = "bonus.frugalusenet.net";
          displayname = "bonus.frugalusenet.net";
          host = "bonus.frugalusenet.net";
          port = 563;
          timeout = 60;
          username = "Misty_TTM";
          connections = 50;
          ssl = true;
          ssl_verify = 3;
          enable = true;
          required = false;
          optional = true;
          priority = 2;
          retentions = 3000;
          quota = "1000G";
        };
      };

      categories = {
        "*" = {
          name = "*";
          order = 0;
          pp = 3;
          script = "None";
          dir = "";
          newzbin = "";
          priority = 0;
        };
        movies = {
          name = "movies";
          order = 1;
          pp = "";
          script = "Default";
          dir = "movies";
          newzbin = "";
          priority = -100;
        };
        tv = {
          name = "tv";
          order = 2;
          pp = "";
          script = "Default";
          dir = "tv";
          newzbin = "";
          priority = -100;
        };
        audio = {
          name = "audio";
          order = 3;
          pp = "";
          script = "Default";
          dir = "audio";
          newzbin = "";
          priority = -100;
        };
        software = {
          name = "software";
          order = 4;
          pp = "";
          script = "Default";
          dir = "software";
          newzbin = "";
          priority = -100;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8085 ];
  sops.secrets."sabnzbd/api_key" = {
    sopsFile = ../../../../secrets/sabnzbd.yaml;
  };
  sops.secrets."sabnzbd/nzb_key" = {
    sopsFile = ../../../../secrets/sabnzbd.yaml;
  };
  sops.secrets."sabnzbd/frugal_password" = {
    sopsFile = ../../../../secrets/sabnzbd.yaml;
  };

  sops.templates."sabnzbd-secrets.ini" = {
    owner = "sabnzbd";
    content = ''
      [misc]
      api_key = ${config.sops.placeholder."sabnzbd/api_key"}
      nzb_key = ${config.sops.placeholder."sabnzbd/nzb_key"}

      [servers]
      [[aunews.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[eunews.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[news.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[newswest.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[sanews.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[asnews.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[usnews.blocknews.net]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
      [[bonus.frugalusenet.com]]
      password = ${config.sops.placeholder."sabnzbd/frugal_password"}
    '';
  };
}
