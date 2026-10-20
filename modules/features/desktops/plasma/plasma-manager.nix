{inputs, ...}: {
  flake-file.inputs.plasma-manager = {
    url = "github:nix-community/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  # Host-agnostic Plasma rice. Hosts with extra monitors can add docks via
  # `programs.puppy.plasma.dockScreens` or append to `programs.plasma.panels`.
  flake.homeModules.plasmaManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];

    options.programs.puppy.plasma.dockScreens = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = [0];
      description = "Screens that get the bottom dock. Screen 0 is always the primary screen.";
    };

    # Everything the rice below refers to by name.
    config.home.packages = with pkgs; [
      amethyst-kde
      penrose-splash
      plasma-applet-window-title
      (tela-circle-icon-theme.override {colorVariants = ["purple"];})
      dracula-theme
      klassy
      darkly
    ];

    config.programs.plasma = {
      enable = true;

      # Default layout on any machine: a top bar on every screen with the system
      # tray only on the primary one (Plasma 6 always numbers it 0), plus a dock
      # on each of dockScreens. One panel per screen rather than `screen = [ ... ]`,
      # since plasma-manager loops that list with JS for...in (indices, not values).
      panels =
        [
          {
            screen = "all";
            location = "top";
            height = 36;
            opacity = "translucent";
            widgets = [
              "org.kde.plasma.kicker"
              {
                name = "org.kde.windowtitle";
                config.Appearance = {
                  txt = "%a";
                  firstSpace = 6;
                  lastSpace = 3;
                  fixedLength = 155;
                  fontSize = 14;
                  visible = false;
                };
              }
              "org.kde.plasma.appmenu"
              "org.kde.plasma.panelspacer"
              {digitalClock.date.position = "besideTime";}
              "org.kde.plasma.panelspacer"
              {
                systemTray.items.hidden = [
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.devicenotifier"
                  "org.kde.plasma.battery"
                  "org.kde.kdeconnect"
                ];
              }
            ];
            extraSettings = ''
              if (screenID != 0) {
                panelWidgets["org.kde.plasma.systemtray"].remove();
              }
            '';
          }
        ]
        ++ map (screen: {
          inherit screen;
          location = "bottom";
          height = 64;
          floating = true;
          lengthMode = "fit";
          opacity = "translucent";
          hiding = "dodgewindows";
          widgets = [
            "org.kde.plasma.kickoff"
            {
              iconTasks.launchers = [
                "applications:firefox.desktop"
                "preferred://filemanager"
                "applications:vesktop.desktop"
                "applications:steam.desktop"
                "applications:kitty.desktop"
                "applications:thunderbird.desktop"
                "applications:dev.zed.Zed.desktop"
              ];
            }
          ];
        })
        config.programs.puppy.plasma.dockScreens;

      workspace = {
        theme = "Amethyst";
        colorScheme = "Amethyst";
        iconTheme = "Tela-circle-purple-dark";
        cursor = {
          theme = "Dracula-cursors";
          size = 24;
        };
        widgetStyle = "Darkly";
        splashScreen.theme = "Penrose";
        windowDecorations = {
          library = "org.kde.klassy";
          theme = "Klassy";
        };
        enableMiddleClickPaste = false;
      };

      kwin = {
        titlebarButtons = {
          left = [];
          right = [
            "help"
            "minimize"
            "maximize"
            "close"
          ];
        };
        effects = {
          blur = {
            enable = true;
            strength = 10;
          };
          translucency.enable = true;
          wobblyWindows.enable = true;
        };
        virtualDesktops = {
          number = 1;
          rows = 1;
        };
        nightLight = {
          enable = true;
          temperature.night = 3600;
        };
        edgeBarrier = 10;
      };

      kscreenlocker = {
        autoLock = false;
        timeout = 0;
      };

      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

      window-rules = [
        {
          description = "Thunderbird";
          match = {
            window-class = {
              value = "thunderbird";
              type = "substring";
              match-whole = false;
            };
            window-types = ["normal"];
          };
          apply = {
            maxsize = {
              value = "2560,1404";
              apply = "force";
            };
            position = {
              value = "1080,516";
              apply = "initially";
            };
          };
        }
        {
          description = "Gamescope";
          match.window-class = {
            value = "gamescope";
            match-whole = false;
          };
          apply.screen = {
            value = 0;
            apply = "initially";
          };
        }
        {
          description = "Discord";
          match = {
            window-class = {
              value = "vesktop";
              type = "substring";
              match-whole = false;
            };
            window-types = ["normal"];
          };
          apply = {
            maxsize = {
              value = "1080,1888";
              apply = "force";
            };
            position = {
              value = "0,32";
              apply = "initially";
            };
          };
        }
        {
          description = "DaVinci Resolve main window always with titlebar and frame";
          match = {
            window-class = {
              value = "resolve";
              match-whole = false;
            };
            window-types = ["normal"];
          };
          apply.decorationpolicy = {
            value = "server";
            apply = "force";
          };
        }
      ];

      shortcuts = {
        kwin."Window Close" = [
          "Alt+F4"
          "Meta+Shift+Q"
        ];
        "services/kitty.desktop"._launch = "Meta+Return";
        "services/org.kde.spectacle.desktop".RectangularRegionScreenShot = [
          "Meta+Shift+S"
          "Meta+Shift+Print"
        ];
        "services/org.kde.plasma-systemmonitor.desktop"._launch = [
          "Ctrl+Shift+Esc"
          "Meta+Esc"
        ];
        "services/net.local.obs-cmd.desktop"._launch = "Meta+F9";
        "services/net.local.obs-cmd-2.desktop"._launch = "F9";
        "com.github.wwmm.easyeffects"."global bypass" = "Ctrl+Alt+E";
        "com.github.wwmm.easyeffects"."microphone monitoring" = "Ctrl+Alt+I";
      };

      # Settings without a first-class plasma-manager option.
      configFile = {
        "klassy/klassyrc" = {
          ButtonColors = {
            ButtonBackgroundColorsActive = "AccentTrafficLights";
            ButtonBackgroundColorsInactive = "AccentTrafficLights";
            ButtonIconColorsActive = "TitleBarText";
            ButtonIconOpacityInactive = 100;
            CloseButtonIconColorActive = "AsSelected";
            CloseButtonIconColorInactive = "AsSelected";
            LockButtonColorsActiveInactive = true;
          };
          ButtonSizing = {
            IntegratedRoundedRectangleBottomPadding = 0;
            SpacerButtonWidthRelative = 50;
          };
          Style.MenuOpacity = 88;
          Windeco = {
            ButtonIconStyle = "StyleMetro";
            DrawTitleBarSeparator = true;
            RoundBottomCornersWhenNoBorders = true;
            WindowCornerRadius = 8;
          };
          WindowOutlineStyle = {
            LockThinWindowOutlineStyleActiveInactive = true;
            ThinWindowOutlineStyleActive = "WindowOutlineShadowColor";
            ThinWindowOutlineStyleInactive = "WindowOutlineShadowColor";
            ThinWindowOutlineThickness = 1.75;
          };
        };
        kdeglobals = {
          General = {
            AccentColor = "146,110,228";
            LastUsedCustomAccentColor = "146,110,228";
            TerminalApplication = "kitty";
            TerminalService = "kitty.desktop";
          };
          KDE.ShowDeleteCommand = false;
          "KFileDialog Settings" = {
            "Show hidden files" = true;
            "Sort by" = "Date";
            "Sort directories first" = true;
            "View Style" = "DetailTree";
          };
        };
        kwinrc = {
          Windows = {
            FocusPolicy = "FocusFollowsMouse";
            DelayFocusInterval = 0;
          };
          TabBox.LayoutName = "big_icons";
          "Effect-wobblywindows" = {
            AdvancedMode = true;
            Drag = 90;
            MoveFactor = 14;
            Stiffness = 6;
            WobblynessLevel = 2;
          };
        };
        dolphinrc = {
          General = {
            DoubleClickViewAction = "none";
            ShowStatusBar = "FullWidth";
          };
          MainWindow.MenuBar = "Disabled";
        };
        powerdevilrc = {
          "AC/Display".TurnOffDisplayWhenIdle = false;
          "AC/SuspendAndShutdown".AutoSuspendAction = 0;
          Inhibitions.BlockedInhibitions = "Steam:Client interface";
        };
        plasmanotifyrc."Applications/org.kde.discover" = {
          ShowBadges = false;
          ShowInHistory = false;
          ShowPopups = false;
        };
      };
    };
  };
}
