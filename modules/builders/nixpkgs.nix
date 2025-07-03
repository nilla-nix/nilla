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
              type = lib.types.attrs.of lib.types.raw;
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
                pkgs = package.settings.pkgs.${system};
              in
              if !(package.settings.pkgs ? ${system}) then
                builtins.throw "[🍦 Nilla] ❌ No package set for system \"${system}\" provided for package \"${package.name}\"."
              else
                pkgs.callPackage package.package package.settings.args
            );
    };
  };
}
