{ lib }:
{
  options = {
    loaders = lib.options.create {
      description = "Handlers for loading Nilla inputs.";
      default.value = { };

      type = lib.types.attrs.of (lib.types.submodule ({ name, config }: {
        options = {
          settings = {
            type = lib.options.create {
              description = "The type of the settings attribute set which can be passed to the load function.";
              type = lib.types.type;
            };

            default = lib.options.create {
              description = "The default value to use for the settings supplied to this loader.";
              type = config.settings.type;
            };
          };

          check = lib.options.create {
            description = "A function which checks to see if an input can be loaded by this loader. This is only used when automatically detecting an input's loader. Setting the loader attribute on an input manually will ensure that specific loader is used.";
            type = lib.types.function lib.types.bool;
            default.value = lib.fp.const false;
          };

          load = lib.options.create {
            description = "A function responsible for loading the input.";
            # NOTE:The return type here needs to be somethign that does not cause an eval on the value to
            # avoid issues with things like Nixpkgs failing to evaluate.
            type = lib.types.function lib.types.raw;
          };
        };
      }));
    };
  };
}
