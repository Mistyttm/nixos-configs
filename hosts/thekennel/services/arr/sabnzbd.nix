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
        top_only = false;
        sfv_check = true;
        script_can_fail = false;
        enable_recursive = true;
        flat_unpack = false;
        par_option = "";
        pre_check = false;
        fail_hopeless_jobs = true;
        fast_fail = true;
        auto_disconnect = true;
        no_dupes = false;
        no_series_dupes = false;
        no_smart_dupes = false;
        dupes_propercheck = true;
        pause_on_pwrar = true;
        ignore_samples = false;
        deobfuscate_final_filenames = true;
        auto_sort = "";
        direct_unpack = true;
        propagation_delay = false;
        folder_rename = true;
        replace_spaces = false;
        replace_underscores = false;
        replace_dots = false;
        safe_postproc = true;
        pause_on_post_processing = false;
        enable_all_par = false;
        sanitize_safe = false;
        new_nzb_on_failure = false;
        history_retention_option = "all";
        history_retention_number = true;
        quota_period = "m";
        enable_tv_sorting = false;
        tv_categories = "tv,";
        enable_movie_sorting = false;
        movie_categories = "movies,";
        enable_date_sorting = false;
        date_categories = "tv,";
        chk_rss_updated = false;
        rss_rate = 60;
        enable_par_cleanup = true;
        process_unpacked_par2 = true;
        enable_unrar = true;
        enable_7zip = true;
        enable_filejoin = true;
        enable_tsjoin = true;
        overwrite_files = false;
        ignore_unrar_dates = false;
        max_url_retries = 10;

        # Whitelist
        host_whitelist = "thekennel, localhost, 127.0.0.1";
      };

      logging = {
        log_level = true;
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
          retention = false;
          expire_date = "";
          quota = "";
          usage_at_start = false;
          priority = false;
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
          retention = false;
          expire_date = "";
          quota = "";
          usage_at_start = false;
          priority = true;
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
          priority = true;
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
          priority = true;
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
          priority = true;
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
          priority = true;
        };
      };

      categories = {
        "*" = {
          name = "*";
          order = false;
          pp = 3;
          script = "None";
          dir = "";
          newzbin = "";
          priority = false;
        };
        movies = {
          name = "movies";
          order = true;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        tv = {
          name = "tv";
          order = 2;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        audio = {
          name = "audio";
          order = 3;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        software = {
          name = "software";
          order = 4;
          pp = "";
          script = "Default";
          dir = "";
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
      api_key = ${config.sops.secrets."sabnzbd/api_key".placeholder}
      nzb_key = ${config.sops.secrets."sabnzbd/nzb_key".placeholder}

      [servers]
      [[aunews.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
      [[eunews.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
      [[news.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
      [[newswest.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
      [[sanews.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
      [[asnews.frugalusenet.com]]
      password = ${config.sops.secrets."sabnzbd/frugal_password".placeholder}
    '';
  };
}
