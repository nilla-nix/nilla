{ lib }:
let
  empty = { __empty__ = true; };
in
{
  config = {
    loaders.nixpkgs = {
      settings = {
        type = lib.types.submodules.of {
          shorthand = true;
          modules = [
            {
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

                # NOTE: We can't call this `config` due to that being a reserved word in the module
                # system. It's not pretty, but it works.
                configuration = lib.options.create {
                  description = "Configuration to apply to the package set.";
                  type = lib.types.attrs.any;
                  default.value = { };
                };
              };
            }
          ];
        };

        default = { };
      };

      load = input: import input.src {
        inherit (input.settings) system overlays;
        config = input.settings.configuration;
      };
    };
  };
}
