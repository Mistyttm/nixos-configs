{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      # Font
      font_family = "MesloLGM Nerd Font";

      # Cursor
      cursor_shape = "beam";
      cursor = "#f8f8f0";

      # Mouse
      mouse_hide_wait = 3;

      # Bell
      enable_audio_bell = true;
      bell_on_tab = "🔔 ";

      # Background and Foreground
      background = "#5a5475";
      foreground = "#f8f8f0";
      selection_background = "#f8f8f2";
      selection_foreground = "#5a5475";
      background_opacity = "0.2";
      background_blur = 1;

      # Colour Table
      color0 = "#040303";
      color1 = "#f92672";
      color2 = "#c2ffdf";
      color3 = "#e6c000";
      color4 = "#c2ffdf";
      color5 = "#ffb8d1";
      color6 = "#c5a3ff";
      color7 = "#f8f8f0";
      color8 = "#6090cb";
      color9 = "#ff857f";
      color10 = "#c2ffdf";
      color11 = "#ffea00";
      color12 = "#c2ffdf";
      color13 = "#ffb8d1";
      color14 = "#c5a3ff";
      color15 = "#f8f8f0";

      # Additional Config
      editor = "nano";
    };
  };
}
