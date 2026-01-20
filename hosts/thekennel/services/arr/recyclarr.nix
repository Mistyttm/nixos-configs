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
    configuration = [
      {
        sonarr = [
          {
            instance_name = "main";
            base_url = "http://localhost:8989";
            api_key = {
              _secret = config.sops.secrets."recyclarr/sonarr_api_key".path;
            };

            # Series quality definition
            quality_definition = {
              type = "series";
              preferred_ratio = 0.5; # Space-efficient
            };

            quality_profiles = [
              {
                name = "WEB-1080p"; # Your quality profile name

                # Unwanted formats (saves space)
                trash_ids = [
                  # Formats to avoid
                  "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK (huge files)
                  "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ - low quality
                  "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                  "fbcb31d8dabd2a319072b84fc0b7249c" # Extras

                  # Block x265 HD (often problematic encodes)
                  "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)

                  # Language
                  "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups

                  # Block higher resolutions to save space
                  "9b27ab6498ec0f31a3353992e19434ca" # DV (WEBDL) 4K
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
                score = -10000; # Block these completely
              }
            ];

            custom_formats = [
              {
                # Preferred WEB sources (space-efficient)
                trash_ids = [
                  "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                  "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                  "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                  "d0c516558625b04b363fa6c5c2c7cfd4" # WEBRip Tier 01
                  "e2227d94b0e7e58f43f13f39ce20df14" # WEBRip Tier 02
                  "55c8c5bbd3c3f4f853ba56cd9ff60c79" # AMZN
                  "9b27ab6498ec0f31a3353992e19434ca" # NF
                  "d2d299244a92b8a52a4c9d4d98b1e665" # DSNP
                  "7be9c0572d8547e0db1c7c88498d611e" # ATVP
                  "f67c9ca88f463a48346062e8ad07713f" # PMTP (Paramount+)
                  "4e9a630db98d5391aec1368a0256e2fe" # CRAV (Crave)
                  "3ac5d84fce98bab1b531393e9c82f467" # PCOK (Peacock)
                  "f27d46a831e6b16fa3fee2c4e5d10984" # STAN (Stan)
                  "77a7b25585c18af08f60b1547bb9b4fb" # CC (Criterion)
                ];
                quality_profiles = [
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
                  "d0c516558625b04b363fa6c5c2c7cfd4" # P2P Groups Tier 02
                  "e2227d94b0e7e58f43f13f39ce20df14" # P2P Groups Tier 03
                ];
                quality_profiles = [
                  {
                    name = "WEB-1080p";
                    score = 50;
                  }
                ];
              }
              {
                # Streaming service tags (for organization)
                trash_ids = [
                  "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                  "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                  "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                ];
                quality_profiles = [
                  {
                    name = "WEB-1080p";
                    score = 25;
                  }
                ];
              }
              {
                # Optional: Season packs (space efficient - one download for whole season)
                trash_ids = [
                  "e53bcd4d8c9bf70000fdc4edc4cf0903" # Season Pack
                ];
                quality_profiles = [
                  {
                    name = "WEB-1080p";
                    score = 15;
                  }
                ];
              }
            ];
          }
        ];

        radarr = [
          {
            instance_name = "main";
            base_url = "http://localhost:7878";
            api_key = {
              _secret = config.sops.secrets."recyclarr/radarr_api_key".path;
            };

            # Quality definitions
            quality_definition = {
              type = "movie";
              preferred_ratio = 0.5;
            };

            # Quality profiles
            quality_profiles = [
              {
                name = "HD-1080p";
                trash_ids = [
                  # Formats to avoid
                  "ed38b889b31be83fda192888e2286d83" # BR-DISK (huge)
                  "90cedc1fea7ea5d11298bebd3d1d3223" # EVO (no WEBDL) - low quality
                  "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # No-RlsGroup - often low quality
                  "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D - not needed
                  "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ - low quality releases
                  "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title) - low quality
                  "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                  "923b6abef9b17f937fab56cfcf89e1f1" # DV (WEBDL) - may cause issues
                  "90a6f9a284dff5103f6346090e6280c8" # LQ groups

                  # Language: Block non-English
                  "7357cf5161efbf8c4d5d0c30b4815ee2" # Dubbed

                  # Codecs to avoid for space efficiency
                  "dc98083864ea246d05a42df0d05f81cc" # x265 (HD) - block old x265 encodes
                ];
                score = -10000; # Block these completely
              }
            ];

            # Custom formats
            custom_formats = [
              {
                # Preferred formats - WEB-DL (space efficient, good quality)
                trash_ids = [
                  "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01 (best WEB sources)
                  "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                  "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
                  "417804f7f2c4308c1f4c5d380d4c4475" # AMZN (Amazon)
                  "9364dd386c9b4a1100dde8264690add7" # NF (Netflix)
                  "b3b3a6ac74ecbd56bcdbefa4799fb9df" # DSNP (Disney+)
                  "40e9380490e748672c2522eaaeb692f7" # ATVP (Apple TV+)
                  "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE (Bluray Core)
                ];
                quality_profiles = [
                  {
                    name = "HD-1080p/2160p";
                    score = 100;
                  }
                ];
              }
              {
                # HDR Formats (prefer HDR10+ and DV for 4K)
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
                quality_profiles = [
                  {
                    name = "HD-1080p/2160p";
                    score = 50;
                  }
                ];
              }
              {
                # Audio - prefer efficient codecs
                trash_ids = [
                  "496f355514737f7d83bf7aa4d24f8169" # TrueHD Atmos
                  "2f22d89048b01681dde8afe203bf2e95" # DTS X
                  "417804f7f2c4308c1f4c5d380d4c4475" # ATMOS (undefined)
                  "1af239278386be2919e1bcee0bde047e" # DD+ ATMOS
                  "3cafb66171b47f226146a0770576870f" # TrueHD
                  "dcf3ec6938fa32445f590a4da84256cd" # DTS-HD MA
                  "a570d4a0e56a2874b64e5bfa55202a1b" # FLAC
                  "e7718d7a3ce595f289bfee26adc178f5" # PCM
                  "8e109e50e0a0b83a5098b056e13bf6db" # DTS-HD HRA
                  "185f1dd7264c4562b9022d963ac37424" # DD+
                  "f691f59e3f13e5a9b8c8c5e46e5af7fb" # DTS-ES
                  "1c1a4c5e823891c75bc50380a6866f73" # DTS
                  "240770601cc226190c367ef59aba7463" # AAC
                  "c2998bd0d90ed5621d8df281e839436e" # DD
                ];
                quality_profiles = [
                  {
                    name = "HD-1080p/2160p";
                    score = 0;
                  } # Just informational
                ];
              }
              {
                # Movie Versions - prefer Theatrical
                trash_ids = [
                  "0f12c086e289cf966fa5948eac571f44" # Theatrical Cut
                  "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                  "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                  "957d0f44b592285f26449575e8b1167e" # Special Edition
                  "eecf3a857724171f968a66cb5719e152" # IMAX
                ];
                quality_profiles = [
                  {
                    name = "HD-1080p/2160p";
                    score = 25;
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  };
}
