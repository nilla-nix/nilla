{ lib, config }:
let
  variantNames = builtins.attrNames config.modules;

  variants = builtins.foldl'
    (acc: variant:
      let
        modules = config.modules.${variant};
      in
      acc // {
        "modules.${variant}" = {
          name = "Modules (${variant})";
          description = "Modules which are available from this Nilla project to use with ${variant}.";

          data = {
            columns = [ "Name" ];
            rows = lib.attrs.mapToList
              (name: module: [ name ])
              modules;
          };
        };
      }
    )
    { }
    variantNames;

  all = {
    name = "Modules";
    description = "Modules which are available from this Nilla project.";

    entries = builtins.attrValues variants;
  };
in
{
  config.explain = variants // {
    modules = all;
  };
}
