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
