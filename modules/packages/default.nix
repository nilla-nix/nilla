{ lib, config }:
let
  cfg = config.packages;

  builders = lib.attrs.mapToList
    (name: builder: builder // {
      inherit name;
    })
    config.builders;
in
{
  options.packages = lib.options.create {
    description = "The packages for this Nilla project.";
    default.value = { };
    type = lib.types.attrs.lazy (lib.types.submodule ({ config, name }:
      let
        package = {
          inherit (config) systems builder settings package;
        };

        matching = builtins.filter
          (builder: package.builder == builder.name)
          builders;

        first = builtins.head matching;

        builder =
          if builtins.length matching == 0 then
            null
          else if builtins.length matching > 1 then
            builtins.trace "[🍦 Nilla] ⚠️ Warning: Multiple builders found for package \"${name}\", using first available: \"${first.name}\"" first
          else first;

        settings =
          if !(builtins.isNull builder) && builder.settings.type.check package.settings then
            package.settings
          else
            null;

        validity =
          if builtins.isNull builder then
            {
              message = "No builder found for package \"${name}\" with builder \"${package.builder}\".";
            }
          else if builtins.isNull settings then
            {
              message = "Invalid settings for builder \"${builder.name}\".";
            }
          else
            null;

        build =
          if builtins.isNull validity then
            builder.build package
          else
            { };
      in
      {
        options = {
          systems = lib.options.create {
            description = "The systems to build this package for.";
            type = lib.types.list.of lib.types.string;
          };

          builder = lib.options.create {
            description = "The builder to use to load this package from its source.";
            type = lib.types.string;
            default.value = "nixpkgs";
          };

          settings = lib.options.create {
            description = "Additional configuration to use when loading this package.";
            type = builder.settings.type;
            default.value = builder.settings.default;
          };

          valid = lib.options.create {
            description = "Whether or not this package is invalid, along with a message.";
            type = lib.types.raw;
            internal = true;
            writable = false;
            default.value =
              if builtins.isNull validity then
                {
                  value = true;
                  message = "";
                }
              else {
                value = false;
                message = validity.message or
                  "package \"${name}\" failed to build due to either invalid settings or an invalid builder.";
              };
          };

          package = lib.options.create {
            description = "The package definition which is built for each of its systems.";
            # NOTE: We can't use a function type here directly due to the merging functionality. Instead we
            # can just check that the value is a function.
            type = lib.types.withCheck lib.types.raw (lib.types.function lib.types.derivation).check;
          };

          build = lib.options.create {
            description = "The built package for each of its systems.";
            type = lib.types.attrs.of lib.types.derivation;
            writable = false;
            default.value = build;
          };
        };
      })
    );
  };

  config = {
    assertions = lib.attrs.mapToList
      (name: package: {
        assertion = package.valid.value;
        message = package.valid.message;
      })
      cfg;
  };
}
