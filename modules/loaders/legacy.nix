{ lib }:
let
  empty = { __empty__ = true; };
in
{
  config = {
    loaders.legacy = {
      settings = {
        type = lib.types.submodule {
          options = {
            target = lib.options.create {
              description = "The relative path to the file to load.";
              type = lib.types.string;
              default.value = "default.nix";
            };

            args = lib.options.create {
              description = "Arguments to pass to the function which is loaded.";
              type = lib.types.any;
              default.value = empty;
            };
          };
        };

        default = { };
      };

      load = input:
        let
          value = import "${input.src}/${input.settings.target}";

          result =
            if builtins.isFunction value && input.settings.args != empty then
              value input.settings.args
            else
              value;
        in
        result;
    };
  };
}
