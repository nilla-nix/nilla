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

  getPackageInfo = name: package:
    let
      systems = package.systems;
      system = builtins.head systems;
      pkg = package.result.${system};
      version = pkg.version or "latest";
      license = getLicense (pkg.license or "Unknown");
      description = pkg.meta.description or "";
    in
    {
      inherit name version license description;
      systems = builtins.concatStringsSep ", " systems;
    };

  packages = {
    name = "Packages";
    description = "Packages are built programs which can be operated on with `nilla build` and `nilla run`.";

    data = {
      columns = [ "Name" "Version" "License" "Systems" ];
      rows = lib.attrs.mapToList
        (name: package:
          let
            info = getPackageInfo name package;
          in
          [
            info.name
            info.version
            info.license
            info.systems
          ]
        )
        config.packages;
    };
  };

  individual = builtins.foldl'
    (result: name:
      let
        package = config.packages.${name};
        info = getPackageInfo name package;
      in
      result // {
        "packages.${name}" = {
          inherit (info) name description;

          data = {
            columns = [ "Version" "License" "Systems" ];
            rows = [ [ info.version info.license info.systems ] ];
          };
        };
      }
    )
    { }
    (builtins.attrNames config.packages);
in
{
  config.explain = individual // {
    inherit packages;
  };
}
