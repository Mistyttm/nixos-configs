{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "colorize"
        "command-not-found"
        "common-aliases"
        "docker"
        "docker-compose"
        "git"
        "gpg-agent"
        "systemd"
      ];
    };
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;
    enableZshIntegration = true;
    settings = {
      format = ''
        [╭─](bold green)$os$hostname$directory$git_branch$git_status$git_state
        [╰─](bold green)$status$jobs$character'';

      right_format = "$cmd_duration$time";

      add_newline = true;

      os = {
        disabled = false;
        style = "bold green";
        symbols.NixOS = " ";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname](bold yellow) ";
        style = "bold yellow";
        disabled = false;
      };

      directory = {
        format = "[ $path]($style)[$read_only]($read_only_style) ";
        style = "bold cyan";
        read_only = " 󰌾";
        read_only_style = "red";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[ $branch(:$remote_branch)]($style) ";
        style = "bold green";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold yellow";
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
        style = "bold yellow";
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
        style = "bold red";
        map_symbol = true;
      };

      jobs = {
        format = "[$symbol$number]($style) ";
        style = "bold yellow";
        symbol = "󱖂 ";
        number_threshold = 1;
        symbol_threshold = 0;
      };

      cmd_duration = {
        format = "[ $duration]($style) ";
        style = "bold yellow";
        min_time = 2000;
        show_milliseconds = false;
      };

      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "dimmed green";
        time_format = "%H:%M";
        utc_time_offset = "+10";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
    };
  };
}
