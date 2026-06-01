{ ... }:
{
  flake.homeModules.zed =
    { pkgs, ... }:
    {
      programs.mcp.servers = {
        "github-copilot-cli" = {
          command = "gh";
          args = [
            "copilot"
            "mcp"
            "serve"
          ];
        };
      };

      programs.zed-editor = {
        enable = true;
        enableMcpIntegration = true;
        extraPackages = with pkgs; [
          nixd
          nil
          alejandra
          deadnix
          nixfmt
          gh
        ];
        installRemoteServer = true;
        extensions = [
          "nix"
          "devicetree"
          "editorconfig"
          "html"
          "dracula"
        ];
        userSettings = {
          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          auto_update = false;
          proxy = "";
          buffer_font_family = "Fira Code";
          buffer_font_features = {
            calt = true;
          };
          buffer_line_height = {
            custom = 2.0;
          };
          soft_wrap = "editor_width";
          terminal = {
            shell = "system";
            font_family = "MesloLGM Nerd Font Mono";
          };
          ui_font_family = "Fira Code";
          icon_theme = "Material Icon Theme";
          edit_predictions = {
            provider = "copilot";
          };
          agent_servers = {
            "github-copilot-cli" = {
              type = "registry";
            };
          };
          context_servers = { };
          focus_follows_mouse = {
            enabled = false;
          };
          bottom_dock_layout = "contained";
          tabs = {
            file_icons = true;
            git_status = true;
          };
          tab_bar = {
            show = true;
          };
          title_bar = {
            button_layout = "platform_default";
            show_menus = false;
            show_user_picture = true;
            show_branch_status_icon = false;
          };
          status_bar = {
            line_endings_button = false;
          };
          colorize_brackets = true;
          autosave = {
            after_delay = {
              milliseconds = 0;
            };
          };
          project_panel = {
            hide_hidden = false;
            hide_root = false;
            diagnostic_badges = true;
            git_status_indicator = true;
            dock = "right";
          };
          outline_panel = {
            dock = "left";
          };
          collaboration_panel = {
            dock = "left";
          };
          agent = {
            dock = "right";
            favorite_models = [ ];
            model_parameters = [ ];
          };
          git_panel = {
            dock = "right";
          };
          git = {
            git_gutter = "tracked_files";
            inline_blame = {
              enabled = true;
              show_commit_summary = true;
            };
          };
          theme = "Dracula";
          ui_font_size = 16;
          buffer_font_size = 16;
          lsp = {
            nixd = {
              settings = {
                diagnostic = {
                  suppress = [ "sema-extra-with" ];
                };
              };
            };
            nil = {
              initialization_options = {
                formatting = {
                  command = [ "alejandra" ];
                };
              };
              settings = {
                diagnostics = {
                  ignored = [ "unused_binding" ];
                };
              };
            };
          };
          format_on_save = "on";
          inlay_hints = {
            enabled = true;
            show_type_hints = true;
            show_parameter_hints = true;
            show_other_hints = true;
          };
        };
      };
    };
}
