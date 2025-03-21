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
              # NOTE: While we can't enforce that every legacy project takes an attribute set
              # as an argument, we can at least handle the cases where it does. Using
              # `lib.types.attrs.any` here is necessary to avoid merging and recursion errors
              # for projects such as Nixpkgs. The downside here is that things like lists
              # will not be merged together, but rather the last one will be taken.
              type = lib.types.either lib.types.attrs.any lib.types.any;
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
