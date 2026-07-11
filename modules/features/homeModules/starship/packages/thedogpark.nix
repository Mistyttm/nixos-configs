{
  inputs,
  palettes,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages.thedogparkStarship = inputs.wrapper-modules.wrappers.starship.wrap {
      inherit pkgs;
      package = pkgs.starship;
      settings = {
        palettes = palettes;
        format = ''
          [╭─](bold_success)$os$hostname$directory$git_branch$git_status$git_state
          [╰─](bold_success)$status$jobs$character'';

        right_format = "$cmd_duration$time";

        palette = "thedogpark";

        add_newline = true;

        os = {
          disabled = false;
          style = "bold_success";
          symbols.NixOS = " ";
        };

        hostname = {
          ssh_only = false;
          format = "[$hostname](bold_warning) ";
          style = "bold_warning";
          disabled = false;
        };

        directory = {
          format = "[ $path]($style)[$read_only]($read_only_style) ";
          style = "bold_path";
          read_only = " 󰌾";
          read_only_style = "error";
          truncation_length = 4;
          truncate_to_repo = false;
        };

        git_branch = {
          format = "[ $branch(:$remote_branch)]($style) ";
          style = "bold_success";
          symbol = " ";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bold_warning";
          conflicted = "󰞇 ";
          ahead = "⇡\${count} ";
          behind = "⇣\${count} ";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
          untracked = "? ";
          stashed = " ";
          modified = "! ";
          staged = "+ ";
          renamed = "» ";
          deleted = "✘ ";
        };

        git_state = {
          format = "[$state( $progress_current/$progress_total)]($style) ";
          style = "bold_warning";
        };

        status = {
          disabled = false;
          format = "[$status $symbol]($style) ";
          symbol = "✗";
          success_symbol = "";
          not_executable_symbol = "󰜺";
          not_found_symbol = "󰍉";
          sigint_symbol = "󰚌";
          signal_symbol = "󱐋";
          style = "bold_error";
          map_symbol = true;
        };

        jobs = {
          format = "[$symbol$number]($style) ";
          style = "bold_warning";
          symbol = "󱖂 ";
          number_threshold = 1;
          symbol_threshold = 0;
        };

        cmd_duration = {
          format = "[ $duration]($style) ";
          style = "bold_warning";
          min_time = 2000;
          show_milliseconds = false;
        };

        time = {
          disabled = false;
          format = "[$time]($style)";
          style = "dimmed_success";
          time_format = "%H:%M";
          utc_time_offset = "+10";
        };

        character = {
          success_symbol = "[❯](bold_success)";
          error_symbol = "[❯](bold_error)";
          vimcmd_symbol = "[❮](bold_success)";
        };
      };
    };
  };
}
