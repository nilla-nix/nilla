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
              default.value = inputs.nixpkgs.result or null;
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
        if builtins.isNull package.settings.pkgs then
          builtins.throw "[🍦 Nilla] ❌ No package set provided for package \"${package.name}\"."
        else
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
