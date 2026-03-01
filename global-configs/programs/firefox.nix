{
  pkgs,
  ...
}:
let
  addons = pkgs.firefox-addons;

  # Extensions not packaged in NUR — fetched directly from AMO
  fetchFirefoxAddon =
    {
      name,
      url,
      sha256,
    }:
    pkgs.fetchFirefoxAddon {
      inherit name url sha256;
    };

  customAddons = {
    smart-https-revived = fetchFirefoxAddon {
      name = "smart-https-revived";
      url = "https://addons.mozilla.org/firefox/downloads/latest/smart-https-revived/latest.xpi";
      sha256 = "sha256-tGDGaEOMF3rBuh0Kao3Db4SY9vHzRL9KvUZcJ2Fhe+s=";
    };
    fb-ad-block = fetchFirefoxAddon {
      name = "fb-ad-block";
      url = "https://addons.mozilla.org/firefox/downloads/latest/fb_ad_block/latest.xpi";
      sha256 = "sha256-opx7aFN6p21nWB5OITDpNtd2ZZKjBBh/4n9IG+kFmzU=";
    };
    reddit-ad-remover = fetchFirefoxAddon {
      name = "reddit-ad-remover";
      url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-ad-remover/latest.xpi";
      sha256 = "sha256-7HkaD5Zw07QVzB+HsHP6Q0zjOHTLyPHNDPn/ZYPnJ8E=";
    };
    blue-blocker = fetchFirefoxAddon {
      name = "blue-blocker";
      url = "https://addons.mozilla.org/firefox/downloads/latest/blue-blocker/latest.xpi";
      sha256 = "sha256-zEyVYhITBDv9ripm/iea0GIozUd8W+MXAMi8hqiSoMk=";
    };
    sky-follower-bridge = fetchFirefoxAddon {
      name = "sky-follower-bridge";
      url = "https://addons.mozilla.org/firefox/downloads/latest/sky-follower-bridge/latest.xpi";
      sha256 = "sha256-pkxyVFkloNqT5mbcglJyLpQsW0sgKC5uDfO881nRU4s=";
    };
    twitch-chat-pronouns = fetchFirefoxAddon {
      name = "twitch-chat-pronouns";
      url = "https://addons.mozilla.org/firefox/downloads/latest/twitch-chat-pronouns/latest.xpi";
      sha256 = "sha256-WMVRRyKB+y00U3Yz2B8+K8Q+4vONWvS0Cym644o1dIA=";
    };
    twitter-real-verified = fetchFirefoxAddon {
      name = "twitter-real-verified";
      url = "https://addons.mozilla.org/firefox/downloads/latest/twitter-real-verified/latest.xpi";
      sha256 = "sha256-FAj5BZfE8rU1+MWMMy2MUbs/Nl95roSXrk75GlvzCMQ=";
    };
    custom-scrollbars = fetchFirefoxAddon {
      name = "custom-scrollbars";
      url = "https://addons.mozilla.org/firefox/downloads/latest/custom-scrollbars/latest.xpi";
      sha256 = "sha256-trXYbTQ7xvqX6yUiwYlQJyZ0bI3u+J2S2rvyo147i4s=";
    };
    linguist-translator = fetchFirefoxAddon {
      name = "linguist-translator";
      url = "https://addons.mozilla.org/firefox/downloads/latest/linguist-translator/latest.xpi";
      sha256 = "sha256-ropaPmYViFdCBUeqsxo4fNLddXpPih+otQEMQQxjKuc=";
    };
    turbo-download-manager = fetchFirefoxAddon {
      name = "turbo-download-manager";
      url = "https://addons.mozilla.org/firefox/downloads/latest/turbo-download-manager/latest.xpi";
      sha256 = "sha256-UJSQ2xsKOLVjBg/U1IESOX4g4J8kI04+DP9g7Xa1WEA=";
    };
    stop-mod-reposts = fetchFirefoxAddon {
      name = "stop-mod-reposts";
      url = "https://addons.mozilla.org/firefox/downloads/latest/stop-mod-reposts/latest.xpi";
      sha256 = "sha256-LIkLLfSIvYLy/nYzO5BuqDi6yOWXI8S3Qg4nfvfagVM=";
    };
    audio-equalizer-wext = fetchFirefoxAddon {
      name = "audio-equalizer-wext";
      url = "https://addons.mozilla.org/firefox/downloads/latest/audio-equalizer-wext/latest.xpi";
      sha256 = "sha256-Wvsgv33LZy3hpXIN4YfaiWMAzbCMOBdb4oWyQIrlKBc=";
    };
    a600-sound-volume = fetchFirefoxAddon {
      name = "600-sound-volume";
      url = "https://addons.mozilla.org/firefox/downloads/latest/600-sound-volume/latest.xpi";
      sha256 = "sha256-cuO36oPO/Exy9MIssodbd8Tg8sDbdDRFtapw8J0Ckaw=";
    };
    canvasplus = fetchFirefoxAddon {
      name = "canvasplus";
      url = "https://addons.mozilla.org/firefox/downloads/latest/canvasplus/latest.xpi";
      sha256 = "sha256-Kic7mHGUd+BHRyaJw/8iBpwj5mNR2NtdACZxrE3PKZs=";
    };
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
    };

    profiles.default = {
      isDefault = true;

      extensions.packages =
        (with addons; [
          # Privacy & Security
          duckduckgo-privacy-essentials
          clearurls
          dont-track-me-google1
          adnauseam
          privacy-pass

          # YouTube
          return-youtube-dislikes
          sponsorblock
          enhancer-for-youtube
          annotations-restored

          # Social Media
          pronoundb
          indie-wiki-buddy
          xkit-rewritten

          # GitHub
          refined-github
          material-icons-for-github
          widegithub

          # Utilities
          bitwarden
          darkreader
          stylus
          tabliss
          tampermonkey
          i-dont-care-about-cookies
          user-agent-string-switcher
          view-image

          # Gaming
          steam-database
          beyond-20

          # Development
          react-devtools

          # Education (Canvas LMS)
          better-canvas
          tasks-for-canvas

          # KDE Integration
          plasma-integration
        ])
        ++ (with customAddons; [
          # Privacy & Security
          smart-https-revived

          # Ad Blocking
          fb-ad-block
          reddit-ad-remover

          # Social Media
          blue-blocker
          sky-follower-bridge
          twitch-chat-pronouns
          twitter-real-verified

          # Utilities
          custom-scrollbars
          linguist-translator
          turbo-download-manager
          stop-mod-reposts

          # Audio & Media
          audio-equalizer-wext
          a600-sound-volume

          # Education
          canvasplus
        ]);

      # Search engine configuration
      search = {
        default = "ddg";
        force = true;
        engines = {
          "DuckDuckGo" = {
            urls = [
              {
                template = "https://duckduckgo.com/";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@ddg" ];
          };
          "Google" = {
            urls = [
              {
                template = "https://www.google.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@g" ];
          };
          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://wiki.nixos.org/favicon.ico";
            definedAliases = [ "@nw" ];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://nixos.org/favicon.ico";
            definedAliases = [ "@np" ];
          };
        };
      };

      settings = {
        # General behaviour
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.download.useDownloadDir" = false;
        "browser.download.autohideButton" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.startup.page" = 3; # Restore previous session
        "browser.newtab.extensionControlled" = true;

        # Scrolling
        "general.autoScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;

        # Clipboard / mouse
        "middlemouse.paste" = false;

        # Privacy
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "network.prefetch-next" = false;

        # Region
        "browser.search.region" = "AU";
        "intl.regional_prefs.use_os_locales" = true;

        # XDG desktop portals (for KDE file pickers etc.)
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.location" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.open-uri" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;

        # GPU / Wayland
        "widget.dmabuf.force-enabled" = true;

        # DRM content
        "browser.eme.ui.firstContentShown" = true;

        # Theming
        "browser.theme.toolbar-theme" = 0; # Dark
      };
    };
  };
}
