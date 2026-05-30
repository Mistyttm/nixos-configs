{
  inputs,
  palettes,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.thekennelStarship = inputs.wrapper-modules.wrappers.starship.wrap {
        inherit pkgs;
        package = pkgs.starship;
        settings = {
          palettes = palettes;
          "$schema" = "https://starship.rs/config-schema.json";

          palette = "thekennel";

          format = "[░▒▓](#a3aed2)[  ](bg:#a3aed2 fg:#090c0c)$hostname[](bg:#769ff0 fg:#a3aed2)$directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

          hostname = {
            disabled = false;
            format = "[ $hostname](bg:light_purple fg:black)";
          };

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
          directory = {
            style = "fg:light_gray bg:blue";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = "…/";
            substitutions = {
              "Documents" = "󰈙 ";
              "Downloads" = " ";
              "Music" = "󰝚 ";
              "Pictures" = " ";
            };
          };
          git_branch = {
            symbol = "";
            style = "bg:dark_blue";
            format = "[[ $symbol $branch ](fg:blue bg:dark_blue)]($style)";
          };

          git_status = {
            style = "bg:dark_blue";
            format = "[[($all_status$ahead_behind )](fg:blue bg:dark_blue)]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:darker_blue";
            format = "[[ $symbol ($version) ](fg:blue bg:darker_blue)]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:darker_blue";
            format = "[[ $symbol ($version) ](fg:blue bg:darker_blue)]($style)";
          };

          golang = {
            symbol = "";
            style = "bg:darker_blue";
            format = "[[ $symbol ($version) ](fg:blue bg:darker_blue)]($style)";
          };

          php = {
            symbol = "";
            style = "bg:darker_blue";
            format = "[[ $symbol ($version) ](fg:blue bg:darker_blue)]($style)";
          };

          time = {
            disabled = false;
            time_format = "%R";
            style = "bg:darkest_blue";
            format = "[[  $time ](fg:light_blue bg:darkest_blue)]($style)";
          };
        };
      };
    };
}
