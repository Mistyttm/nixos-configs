{ self, ... }:
{
  flake.hydraJobs.nixos =
    if self.nixosConfigurations == null then
      { }
    else
      let
        names = builtins.attrNames self.nixosConfigurations;
        entries = builtins.map (
          name:
          let
            cfg = builtins.getAttr name self.nixosConfigurations;
          in
          {
            name = name;
            value = if cfg == null then null else cfg.config.system.build.toplevel;
          }
        ) names;
        filtered = builtins.filter (e: e.value != null) entries;
      in
      builtins.listToAttrs filtered;
}
