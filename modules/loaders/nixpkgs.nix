{ lib }:
let
  empty = { __empty__ = true; };
in
{
  config = {
    loaders.nixpkgs = {
      settings = {
        type = lib.types.submodule {
          options = {
            system = lib.options.create {
              description = "The system to build the package set for.";
              type = lib.types.string;
              default.value = "x86_64-linux";
            };

            overlays = lib.options.create {
              description = "A list of overlays to apply to the package set.";
              type = lib.types.list.of (lib.types.function lib.types.raw);
              default.value = [ ];
            };

            config = lib.options.create {
              description = "Configuration to apply to the package set.";
              type = lib.types.attrs.any;
              default.value = { };
            };
          };
        };

        default = { };
      };

      load = input: import input.src input.settings;
    };
  };
}
