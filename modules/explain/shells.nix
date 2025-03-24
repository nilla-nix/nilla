{ config, lib }:
let
  getLicense = license:
    if builtins.isString license then
      license
    else if builtins.isAttrs license then
      license.spdxId or license.shortName or license.fullName or "Unknown"
    else if builtins.isList license then
      builtins.concatStringsSep ", " (builtins.map getLicense license)
    else
      "Unknown";

  getShellInfo = name: shell:
    let
      systems = shell.systems;
      system = builtins.head systems;
      pkg = shell.result.${system};
      version = pkg.version or "latest";
      license = getLicense (pkg.license or "Unknown");
      description = pkg.meta.description or "";
    in
    {
      inherit name version license description;
      systems = builtins.concatStringsSep ", " systems;
    };

  shells = {
    name = "Shells";
    description = "Shells are development environments which can be used with `nilla shell`.";

    data = {
      columns = [ "Systems" ];
      rows = lib.attrs.mapToList
        (name: shell:
          let
            info = getShellInfo name shell;
          in
          [
            info.systems
          ]
        )
        config.shells;
    };
  };

  individual = builtins.foldl'
    (result: name:
      let
        shell = config.shells.${name};
        info = getShellInfo name shell;
      in
      result // {
        "shells.${name}" = {
          inherit (info) name description;

          data = {
            columns = [ "Systems" ];
            rows = [ [ info.systems ] ];
          };
        };
      }
    )
    { }
    (builtins.attrNames config.shells);
in
{
  config.explain = individual // {
    inherit shells;
  };
}
