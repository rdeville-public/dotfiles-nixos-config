{
  userCfg,
  pkgs,
  mkLib,
  ...
}: {
  programs = {
    kitty = {
      enable = true;
      package = mkLib.nixGLWrap pkgs.kitty userCfg;
      keybindings = {
        "alt+shift+t" = "new_tab";
        "alt+shift+s" = "select_tab";
        "alt+shift+q" = "close_window";
        "alt+shift+h" = "previous_tab";
        "alt+shift+l" = "next_tab";
        "alt+ctrl+shift+h" = "move_tab_backward";
        "alt+ctrl+shift+l" = "move_tab_forward";
      };
      settings =
        {
          # Kitty Configuration File
          # https://sw.kovidgoyal.net/kitty/conf
          startup_session = "none";
          # Font config
          # -----------------------------------------------------------------------------
          font_family = "terminal-font";
          bold_font = "auto";
          italic_font = "auto";
          bold_italic_font = "auto";
          font_size = "10.0";
          disable_ligatures = "always";
          # Cursor Customization
          # -----------------------------------------------------------------------------
          cursor = "#CCCCCC";
          cursor_text_color = "#000000";
          cursor_blink_interval = "0";
          # Scrollback
          # -----------------------------------------------------------------------------
          scrollback_lines = "5000";
          scrollback_pager_history_size = "1024";
          # Mouse
          # -----------------------------------------------------------------------------
          mouse_hide_wait = "-1";
          # Terminal Bell
          # -----------------------------------------------------------------------------
          enable_audio_bell = "no";
          # Window Layout
          # -----------------------------------------------------------------------------
          hide_window_decorations = "yes";
          enabled_layouts = "stack";
          # Advanced
          # -----------------------------------------------------------------------------
          allow_remote_control = "no";
          notify_on_cmd_finish = "unfocused 15 notify";
          # Tab Bar
          # -----------------------------------------------------------------------------
          tab_bar_edge = "top";
          tab_bar_style = "powerline";
          tab_bar_min_tabs = "1";
          inactive_tab_foreground = "#9E9E9E";
          inactive_tab_background = "#212121";
          inactive_tab_font_style = "normal";

          # Color Scheme
          # -----------------------------------------------------------------------------
          background_opacity = "0.75";
          foreground = "#EEEEEE";
          background = "#000000";
          selection_foreground = "#000000";
          selection_background = "#FFF9C4";
          # Black
          color0 = "#000000";
          color8 = "#616161";
          # Red
          color1 = "#E53935";
          color9 = "#EF5350";
          # Green
          color2 = "#43A047";
          color10 = "#66BB6A";
          # Yellow
          color3 = "#FDD835";
          color11 = "#FFEE58";
          # Blue
          color4 = "#1E88E5";
          color12 = "#42A5F5";
          # Magenta
          color5 = "#8E24AA";
          color13 = "#AB47BC";
          # Cyan
          color6 = "#00ACC1";
          color14 = "#26C6DA";
          # White
          color7 = "#E0E0E0";
          color15 = "#FAFAFA";
        }
        // (import ./hosts/${userCfg.hostname}.nix);
    };
  };
}
