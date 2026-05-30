{
  inputs,
  palettes,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.puppypcStarship = inputs.wrapper-modules.wrappers.starship.wrap {
        inherit pkgs;
        package = pkgs.starship;
        settings = {
          palettes = palettes;

          "$schema" = "https://starship.rs/config-schema.json";

          format = "[](red)$os$username[](bg:peach fg:red)$directory[](bg:yellow fg:peach)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$docker_context$conda[](fg:sapphire bg:lavender)$time[](fg:lavender)$cmd_duration$line_break$character";

          palette = "catppuccin_frappe";
          os = {
            disabled = false;
            style = "bg:red fg:crust";
            symbols = {
              Windows = "";
              Ubuntu = "󰕈";
              SUSE = "";
              Raspbian = "󰐿";
              Mint = "󰣭";
              Macos = "󰀵";
              Manjaro = "";
              Linux = "󰌽";
              Gentoo = "󰣨";
              Fedora = "󰣛";
              Alpine = "";
              Amazon = "";
              Android = "";
              Arch = "󰣇";
              Artix = "󰣇";
              CentOS = "";
              Debian = "󰣚";
              Redhat = "󱄛";
              RedHatEnterprise = "󱄛";
              NixOS = "";
            };
          };
          username = {
            show_always = true;
            style_user = "bg:red fg:crust";
            style_root = "bg:red fg:crust";
            format = "[ $user]($style)";
          };
          directory = {
            style = "bg:peach fg:crust";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = "…/";
            substitutions = {
              "Documents" = "󰈙 ";
              "Downloads" = " ";
              "Music" = "󰝚 ";
              "Pictures" = " ";
              "Developer" = "󰲋 ";
            };
          };
          git_branch = {
            symbol = "";
            style = "bg:yellow";
            format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
          };
          git_status = {
            style = "bg:yellow";
            format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
          };
          nodejs = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          c = {
            symbol = " ";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          golang = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          php = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          java = {
            symbol = " ";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          kotlin = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          haskell = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version) ](fg:crust bg:green)]($style)";
          };

          python = {
            symbol = "";
            style = "bg:green";
            format = "[[ $symbol( $version)(\\($virtualenv\\)) ](fg:crust bg:green)]($style)";
          };

          docker_context = {
            symbol = "";
            style = "bg:sapphire";
            format = "[[ $symbol( $context) ](fg:crust bg:sapphire)]($style)";
          };

          conda = {
            symbol = "  ";
            style = "fg:crust bg:sapphire";
            format = "[$symbol$environment ]($style)";
            ignore_base = false;
          };

          time = {
            disabled = false;
            time_format = "%R";
            style = "bg:lavender";
            format = "[[   $time ](fg:crust bg:lavender)]($style)";
          };

          line_break = {
            disabled = true;
          };

          character = {
            disabled = false;
            success_symbol = "[❯](bold fg:green)";
            error_symbol = "[❯](bold fg:red)";
            vimcmd_symbol = "[❮](bold fg:green)";
            vimcmd_replace_one_symbol = "[❮](bold fg:lavender)";
            vimcmd_replace_symbol = "[❮](bold fg:lavender)";
            vimcmd_visual_symbol = "[❮](bold fg:yellow)";
          };

          cmd_duration = {
            show_milliseconds = true;
            format = "  in $duration ";
            style = "bg:lavender";
            disabled = false;
            show_notifications = true;
            min_time_to_notify = 45000;
          };
        };
      };
    };
}
