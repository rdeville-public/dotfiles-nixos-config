{
  config,
  lib,
  pkgs,
  ...
}: let
  abook = builtins.attrValues config.accounts.contact.accounts;
in {
  programs = {
    abook = {
      enable = abook != [];
      extraConfig = ''
        # Abook configuration file
        #
        # Declare a few custom fields
        # field pager = Pager
        # field address_lines = Address, list
        # field birthday = Birthday, date
        # Define how fields should be displayed in tabs
        view CONTACT = name, email
        view ADDRESS = address_lines, city, state, zip, country
        view PHONE = phone, workphone, pager, mobile, fax
        view OTHER = url, birthday
        # Preserve any unknown field while loading an abook database
        set preserve_fields=all
        # Automatically save database on exit
        set autosave=true
        # Format of entries lines in list
        set index_format=" {name:10} {email:10} {phone:20|workphone|mobile}"
        # Show all email addresses in list
        set show_all_emails=true
        # Command used to start mutt
        set mutt_command=mutt
        # Return all email addresses to a mutt query
        set mutt_return_all_emails=true
        # Command used to print
        set print_command=lpr
        # Command used to start the web browser
        set www_command=firefox
        # Address style [eu|us|uk]
        set address_style=eu
        # Use ASCII characters only
        set use_ascii_only=false
        # Prevent double entry
        set add_email_prevent_duplicates=true
        # Field to be used with "sort by field" command
        set sort_field=nick
        # Show cursor in main display
        set show_cursor=false

        # Color settings:
        # set color_header_fg=color Foreground color for header bar
        # set color_header_bg=color Background color for header bar
        # set color_footer_fg=color Foreground color for footer bar
        # set color_footer_bg=color Background color for footer bar
        # set color_list_even_fg=color Foreground color for normal list entries with even index in the list (starting with index 0)
        # set color_list_even_bg=color Background color for normal list entries with even index in the list (starting with index 0)
        # set color_list_odd_fg=color Foreground color for normal list entries with odd index in the list (starting with index 0)
        # set color_list_odd_bg=color Background color for normal list entries with odd index in the list (starting with index 0)
        # set color_list_header_fg=color Foreground color for the list header
        # set color_list_header_bg=color Background color for the list header
        # set color_list_highlight_fg=color Foreground color for highlighted list entries
        # set color_list_highlight_bg=color Background color for highlighted list entries
        # set color_tab_border_fg=color Foreground color for tab borders on details page
        # set color_tab_border_bg=color Background color for tab borders on details page
        # set color_tab_label_fg=color Foreground color for tab labes on details page
        # set color_tab_label_bg=color Background color for tab labes on details page
        # set color_field_name_fg=color Foreground color for field names on details page
        # set color_field_name_bg=color Background color for field names on details page
        # set color_field_value_fg=color Foreground color for field values on details page
        # set color_field_value_bg=color Background color for field values on details page
        # set Where color can be: default, black, red, green, yellow, blue, magenta, cyan, white
      '';
    };
  };
}
