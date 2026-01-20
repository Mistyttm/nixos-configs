{ config, ... }:
{
  sops.secrets."recyclarr/sonarr_api_key" = {
    sopsFile = ../../../../secrets/media.yaml;
  };

  sops.secrets."recyclarr/radarr_api_key" = {
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
            _secret = config.sops.secrets."recyclarr/sonarr_api_key".path;
          };

          quality_definition = {
            type = "series";
            preferred_ratio = 0.5;
          };

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
                "9b27ab6498ec0f31a3353992e19434ca" # DV (WEBDL) - REMOVED DUPLICATE
                "7878c33f1963fefb3d6c8657d46c2f0a" # DV HDR10 4K
                "1f733af03141f068a540eec352589a89" # DV HLG 4K
                "27954b0a80aab882522a88a4d9eae1cd" # DV SDR 4K
                "6d0d8de7b57e35518ac0308b0ddf404e" # DV 4K
                "bb019e1cd00f304f80971c965de064dc" # HDR10+ 4K
                "3497799d29a085e2ac2df9d468413c94" # HDR10 4K
                "3e2c4e748b64a1a1118e0ea3f4cf6875" # HDR undefined 4K
                "a3d82cbef5039f8d295478d28a887159" # HLG 4K
                "17e889ce13117940092308f48b48b45b" # HLG 4K
                "2a7e3be05d3861d6df7171ec74cad727" # PQ 4K
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
                "55c8c5bbd3c3f4f853ba56cd9ff60c79" # AMZN
                # REMOVED: "9b27ab6498ec0f31a3353992e19434ca" # NF (this was the duplicate - it's DV not NF)
                "d2d299244a92b8a52a4c9d4d98b1e665" # DSNP
                "7be9c0572d8547e0db1c7c88498d611e" # ATVP
                "f67c9ca88f463a48346062e8ad07713f" # PMTP
                "4e9a630db98d5391aec1368a0256e2fe" # CRAV
                "3ac5d84fce98bab1b531393e9c82f467" # PCOK
                "f27d46a831e6b16fa3fee2c4e5d10984" # STAN
                "77a7b25585c18af08f60b1547bb9b4fb" # CC
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
                "d6819cba26b1a6508138d25fb5e32293" # Scene
                "1b3994c551cbb92a2c781af061f4ab44" # P2P Groups Tier 01
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
                "e53bcd4d8c9bf70000fdc4edc4cf0903" # Season Pack
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
            _secret = config.sops.secrets."recyclarr/radarr_api_key".path;
          };

          quality_definition = {
            type = "movie";
            preferred_ratio = 0.5;
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
                "ed38b889b31be83fda192888e2286d83" # BR-DISK
                "90cedc1fea7ea5d11298bebd3d1d3223" # EVO
                "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup
                "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                "7357cf5161efbf8c4d5d0c30b4815ee2" # Dubbed
                "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
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
                "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                "417804f7f2c4308c1f4c5d380d4c4475" # AMZN
                "9364dd386c9b4a1100dde8264690add7" # NF
                "b3b3a6ac74ecbd56bcdbefa4799fb9df" # DSNP
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
                "08d6d8834ad9ec87b1dc7ec8148e7a1f" # PQ
                "9364dd386c9b4a1100dde8264690add7" # HLG
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
                "0f12c086e289cf966fa5948eac571f44" # Theatrical Cut
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
            {
              # Block AI upscales
              trash_ids = [
                "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
              ];
              assign_scores_to = [
                {
                  name = "HD-1080p";
                  score = -10000;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
