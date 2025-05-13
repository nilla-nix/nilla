{ lib }:
let
  pins = import ../../npins;
  compat = pins.flake-compat;
in
{
  config = {
    loaders.flake = {
      settings = {
        type = lib.types.submodule {
          options = {
            target = lib.options.create {
              description = "The relative path to the file to load.";
              type = lib.types.string;
              default.value = "flake.nix";
            };

            inputs = lib.options.create {
              description = "Inputs to replace in the loaded flake.";
              type = lib.types.attrs.of lib.types.raw;
              default.value = { };
            };
          };
        };

        default = { };
      };

      load = input:
        let
          value = compat.load {
            src = builtins.dirOf "${input.src}/${input.settings.target}";

            replacements = input.settings.inputs;
          };
        in
        value;
    };
  };
}
