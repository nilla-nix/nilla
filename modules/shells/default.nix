{ lib, config }:
let
  cfg = config.shells;

  builders = lib.attrs.mapToList
    (name: builder: builder // {
      inherit name;
    })
    config.builders;
in
{
  options.shells = lib.options.create {
    description = "The shells for this Nilla project.";
    default.value = { };
    type = lib.types.attrs.lazy
      (lib.types.submodules.portable {
        module = ({ config, name }:
          let
            shell = {
              inherit (config) systems builder settings;

              package = config.shell;
            };

            matching = builtins.filter
              (builder: shell.builder == builder.name)
              builders;

            first = builtins.head matching;

            builder =
              if builtins.length matching == 0 then
                null
              else if builtins.length matching > 1 then
                builtins.trace "[🍦 Nilla] ⚠️ Warning: Multiple builders found for shell \"${name}\", using first available: \"${first.name}\"" first
              else first;

            settings =
              if !(builtins.isNull builder) && builder.settings.type.check shell.settings then
                shell.settings
              else
                null;

            validity =
              if builtins.isNull builder then
                {
                  message = "No builder found for shell \"${name}\" with builder \"${shell.builder}\".";
                }
              else if builtins.isNull settings then
                {
                  message = "Invalid settings for builder \"${builder.name}\".";
                }
              else
                null;

            result =
              if builtins.isNull validity then
                builder.build shell
              else
                { };
          in
          {
            options = {
              systems = lib.options.create {
                description = "The systems to build this shell for.";
                type = lib.types.list.of lib.types.string;
              };

              builder = lib.options.create {
                description = "The builder to use to load this shell from its source.";
                type = lib.types.string;
                default.value = "nixpkgs";
              };

              settings = lib.options.create {
                description = "Additional configuration to use when loading this shell.";
                type = builder.settings.type;
                default.value = builder.settings.default;
              };

              valid = lib.options.create {
                description = "Whether or not this shell is invalid, along with a message.";
                type = lib.types.raw;
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
                      "shell \"${name}\" failed to build due to either invalid settings or an invalid builder.";
                  };
              };

              shell = lib.options.create {
                description = "The shell definition which is built for each of its systems.";
                # NOTE: We can't use a function type here directly due to the merging functionality. Instead we
                # can just check that the value is a function.
                type = lib.types.withCheck lib.types.raw (lib.types.function lib.types.derivation).check;
              };

              result = lib.options.create {
                description = "The built shell for each of its systems.";
                type = lib.types.attrs.of lib.types.derivation;
                writable = false;
                default.value = result;
              };
            };
          });
      });
  };

  config = {
    assertions = lib.attrs.mapToList
      (name: shell: {
        assertion = shell.valid.value;
        message = shell.valid.message;
      })
      cfg;
  };
}
