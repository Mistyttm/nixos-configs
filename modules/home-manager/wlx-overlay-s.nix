{ lib, options, config, pkgs, ... }: 
with lib; 
let 
  cfg = config.programs.wlx-overlay-s;
  yamlFormat = pkgs.formats.yaml { };
  defaultWatchData = builtins.fromJSON (builtins.readFile (pkgs.runCommand "fetch-remote-yaml" {} ''
    ${pkgs.curl}/bin/curl -sL "https://raw.githubusercontent.com/galister/wlx-overlay-s/main/src/res/watch.yaml" | ${pkgs.yq}/bin/yq -o=json > $out
  ''));
  defaultSettingsData = builtins.fromJSON (builtins.readFile (pkgs.runCommand "fetch-remote-yaml" {} ''
    ${pkgs.curl}/bin/curl -sL "https://github.com/galister/wlx-overlay-s/raw/main/src/res/settings.yaml" | ${pkgs.yq}/bin/yq -o=json > $out
  ''));

  defaultFilePath = "${config.xdg.configHome}/wlxoverlay";
in {
  options.programs.wlx-overlay-s = {
    enable = mkEnableOption "Enable wlx-overlay-s";

    config = {
      watch = mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.any);
        default = defaultWatchData;
        description = "Config for customising the watch";
      };
      settings = mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.any);
        default = defaultSettingsData;
        description = "Config for customising the settings";
      };
      timezones = mkOption {
        type = lib.types.listOf lib.types.string;
        default = [ "Europe/Oslo" "America/New_York" ];
        description = "List of timezones to use for the watch";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file.${defaultFilePath} = {
      text = yamlFormat.generate "watch.yaml" cfg.config.watch;
    };
    home.file.${defaultFilePath} = {
      text = yamlFormat.generate "settings.yaml" cfg.config.settings;
    };
    home.file.${defaultFilePath} = {
      text = yamlFormat.generate "timezones.yaml" cfg.config.timezones;
    };
  };
}
