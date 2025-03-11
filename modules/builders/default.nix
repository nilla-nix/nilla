{ lib }:
{
  options = {
    builders = lib.options.create {
      description = "Handlers for building packages.";
      default.value = { };

      type = lib.types.attrs.of (lib.types.submodule ({ name, config }: {
        options = {
          settings = {
            type = lib.options.create {
              description = "The type of the settings attribute set which can be passed to the build function.";
              type = lib.types.type;
            };

            default = lib.options.create {
              description = "The default value to use for the settings supplied to this builder.";
              type = config.settings.type;
            };
          };

          build = lib.options.create {
            description = "A function responsible for building the package.";
            type = lib.types.function lib.types.raw;
          };
        };
      }));
    };
  };
}
