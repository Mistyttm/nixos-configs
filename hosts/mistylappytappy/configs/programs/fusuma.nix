{ pkgs, ... }:
{
  services.fusuma = {
    enable = false;
    extraPackages = with pkgs; [
      xdotool
      coreutils
      xorg.xprop
    ];
    settings = {
      swipe = {
        "4" = {
          right = {
            command = "xdotool key alt+Right"; # History forward
          };
          left = {
            command = "xdotool key alt+Left"; # History back
          };
          up = {
            command = "xdotool key ctrl+t"; # Open new tab
            keypress = {
              LEFTSHIFT = {
                command = "xdotool key --clearmodifiers ctrl+shift+t"; # Open last closed tab
              };
            };
          };
          down = {
            command = "xdotool key ctrl+w"; # Close tab
          };
        };
        "3" = {
          left = {
            workspace = "next"; # Switch to next workspace
            keypress = {
              LEFTSHIFT = {
                window = "next"; # Move window to next workspace
              };
              LEFTMETA = {
                command = "xdotool key --clearmodifiers super+ctrl+Left"; # Move window to left side
              };
            };
          };
          right = {
            workspace = "prev"; # Switch to previous workspace
            keypress = {
              LEFTSHIFT = {
                window = "prev"; # Move window to previous workspace
              };
              LEFTMETA = {
                command = "xdotool key --clearmodifiers super+ctrl+Right"; # Move window to right side
              };
            };
          };
          up = {
            command = "xdotool key Control_L+F10"; # Workspace overview
            keypress = {
              LEFTMETA = {
                window = {
                  maximized = "toggle"; # Toggle Maximize/Unmaximize Window
                };
              };
            };
          };
          down = {
            command = "xdotool key Control_L+F12"; # minimise all windows
            keypress = {
              LEFTMETA = {
                window = "close"; # Close window
              };
            };
          };
        };
      };
      pinch = {
        "2" = {
          "in" = {
            command = "xdotool keydown ctrl click 4 keyup ctrl"; # Zoom in
          };
          "out" = {
            command = "xdotool keydown ctrl click 5 keyup ctrl"; # Zoom out
          };
        };
        "4" = {
          "in" = {
            command = "xdotool key super+a"; # Window overview
          };
          "out" = {
            command = "xdotool key super+s"; # Workspace overview
          };
        };
      };
      plugin = {
        inputs = {
          libinput_command_input = {
            # options for lib/plugin/inputs/libinput_command_input
            enable-tap = true; # click to tap
            enable-dwt = true; # disable tap while typing
            show-keycodes = true; # https://github.com/iberianpig/fusuma-plugin-keypress#add-show-keycode-option
          };
        };
      };
    };
  };
}
