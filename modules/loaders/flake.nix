{ pins, lib }:
let
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
          };
        };

        default = { };
      };

      load = input:
        let
          value = import compat { src = builtins.dirOf "${input.src}/${input.settings.target}"; };
        in
        value.defaultNix;
    };
  };
}
