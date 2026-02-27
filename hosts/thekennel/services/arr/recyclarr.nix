{ config, ... }:
{
  sops.secrets."sonarr_api_key" = {
    sopsFile = ../../../../secrets/media.yaml;
  };

  sops.secrets."radarr_api_key" = {
    sopsFile = ../../../../secrets/media.yaml;
  };

  services.recyclarr = {
    enable = true;
    schedule = "daily";
    configuration = {
      sonarr = {
        sonarr-main = {
          base_url = "http://localhost:8989";
          api_key = {
            _secret = config.sops.secrets."sonarr_api_key".path;
          };

          quality_definition = {
            type = "series";
            preferred_ratio = 0.0;
          };

          quality_profiles = [
            {
              name = "WEB-1080p";
              reset_unmatched_scores = {
                enabled = true;
              };
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
                until_score = 10000;
              };
              min_format_score = 0;
              quality_sort = "top";
              qualities = [
                {
                  name = "WEB 1080p";
                  qualities = [
                    "WEBDL-1080p"
                    "WEBRip-1080p"
                  ];
                }
                {
                  name = "WEB 720p";
                  qualities = [
                    "WEBDL-720p"
                    "WEBRip-720p"
                  ];
                }
                {
                  name = "WEB 480p";
                  qualities = [
                    "WEBDL-480p"
                    "WEBRip-480p"
                  ];
                }
              ];
            }
          ];

          custom_formats = [
            {
              # Unwanted formats - block these
              trash_ids = [
                "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
              ];
              assign_scores_to = [
                {
                  name = "WEB-1080p";
                  score = -10000;
                }
              ];
            }
            {
              # Preferred WEB sources
              trash_ids = [
                "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
                "170b1d363bd8516fbf3a3eb05d4faff6" # NF
                "84272245b2988854bfb76a16e60baea5" # DSNP
                "40e9380490e748672c2522eaaeb692f7" # ATVP
                "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
              ];
              assign_scores_to = [
                {
                  name = "WEB-1080p";
                  score = 100;
                }
              ];
            }
            {
              # Scene/P2P groups
              trash_ids = [
                "1b3994c551cbb92a2c781af061f4ab44" # Scene
                "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
              ];
              assign_scores_to = [
                {
                  name = "WEB-1080p";
                  score = 50;
                }
              ];
            }
            {
              # Season packs
              trash_ids = [
                "3bc5f395426614e155e585a2f056cdf1" # Season Pack
              ];
              assign_scores_to = [
                {
                  name = "WEB-1080p";
                  score = 15;
                }
              ];
            }
            {
              # Block AI upscales
              trash_ids = [
                "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
              ];
              assign_scores_to = [
                {
                  name = "WEB-1080p";
                  score = -10000;
                }
              ];
            }
          ];
        };
      };

      radarr = {
        radarr-main = {
          base_url = "http://localhost:7878";
          api_key = {
            _secret = config.sops.secrets."radarr_api_key".path;
          };

          quality_definition = {
            type = "movie";
            preferred_ratio = 0.0; # Prefer smallest file size
          };

          quality_profiles = [
            {
              name = "WEB-1080p";
              reset_unmatched_scores = {
                enabled = true;
              };
              upgrade = {
                allowed = true;
                until_quality = "WEB 1080p";
                until_score = 10000;
              };
              min_format_score = 0;
              quality_sort = "top";
              qualities = [
                {
                  name = "WEB 2160p";
                  qualities = [
                    "WEBDL-2160p"
                    "WEBRip-2160p"
                  ];
                }
                {
                  name = "WEB 1080p";
                  qualities = [
                    "WEBDL-1080p"
                    "WEBRip-1080p"
                  ];
                }
                {
                  name = "WEB 720p";
                  qualities = [
                    "WEBDL-720p"
                    "WEBRip-720p"
                  ];
                }
                {
                  name = "WEB 480p";
                  qualities = [
                    "WEBDL-480p"
                    "WEBRip-480p"
                  ];
                }
              ];
            }
          ];

          custom_formats = [
            {
              # Unwanted formats - block these
              trash_ids = [
                "ed38b889b31be83fda192888e2286d83" # BR-DISK
                "90cedc1fea7ea5d11298bebd3d1d3223" # EVO (no WEBDL)
                "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                "90a6f9a284dff5103f6346090e6280c8" # LQ
                "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated (this is "Dubbed" equivalent)
                "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = -10000;
                }
              ];
            }
            {
              # Preferred WEB sources
              trash_ids = [
                "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
                "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
                "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
                "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
                "170b1d363bd8516fbf3a3eb05d4faff6" # NF
                "84272245b2988854bfb76a16e60baea5" # DSNP
                "40e9380490e748672c2522eaaeb692f7" # ATVP
                "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = 100;
                }
              ];
            }
            {
              # HDR formats
              trash_ids = [
                "e23edd2482476e595fb990b12e7c609c" # DV HDR10
                "58d6a88f13e2db7f5059a41047876f00" # DV
                "55d53828b9d81cbe20b02efd00aa0efd" # DV HLG
                "a3e19f8f627608af0211acd02bf89735" # DV SDR
                "b974a6cd08c1066250f1f177d7aa1225" # HDR10+
                "dfb86d5941bc9075d6af23b09c2aeecd" # HDR10
                "e61e28db95d22bedcadf030b8f156d96" # HDR
                "2a4d9069cc1fe3242ff9bdaebed239bb" # HDR (undefined)
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = 50;
                }
              ];
            }
            {
              # Movie versions
              trash_ids = [
                "0f12c086e289cf966fa5948eac571f44" # Hybrid
                "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                "957d0f44b592285f26449575e8b1167e" # Special Edition
                "eecf3a857724171f968a66cb5719e152" # IMAX
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = 25;
                }
              ];
            }
            {
              # Audio codecs (informational only)
              trash_ids = [
                "496f355514737f7d83bf7aa4d24f8169" # TrueHD Atmos
                "2f22d89048b01681dde8afe203bf2e95" # DTS X
                "1af239278386be2919e1bcee0bde047e" # DD+ ATMOS
                "185f1dd7264c4562b9022d963ac37424" # DD+
                "240770601cc226190c367ef59aba7463" # AAC
                "c2998bd0d90ed5621d8df281e839436e" # DD
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = 0;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
