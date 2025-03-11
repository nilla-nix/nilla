{ lib, config }:
let
  inherit (config) inputs;
in
{
  config = {
    builders.nixpkgs = {
      settings = {
        type = lib.types.submodule {
          options = {
            pkgs = lib.options.create {
              description = "The Nixpkgs instance to use to build the package.";
              type = lib.types.raw;
              default.value =
                if inputs ? nixpkgs then
                  inputs.nixpkgs.loaded
                else
                  null;
            };

            args = lib.options.create {
              description = "Arguments to pass to the builder.";
              type = lib.types.any;
              default.value = { };
            };
          };
        };

        default = { };
      };

      build = package:
        lib.attrs.generate
          package.systems
          (system:
            let
              pkgs = import package.settings.pkgs.path {
                inherit system;
                inherit (package.settings.pkgs) config overlays;
              };
            in
            pkgs.callPackage package.package package.settings.args
          );
    };
  };
}
