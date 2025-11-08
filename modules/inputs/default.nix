{ lib, config }:
let
  cfg = lib.attrs.filter (n: v: n != "__functor") config.inputs;

  loaders = lib.attrs.mapToList
    (name: loader: loader // {
      inherit name;
    })
    config.loaders;

  customLoaders = builtins.filter
    (loader: !(builtins.elem loader.name [
      "flake"
      "legacy"
      "nilla"
      "nixpkgs"
      "raw"
    ]))
    loaders;
in
{
  options.inputs = lib.options.create {
    description = "The inputs for this Nilla project.";
    default.value = { };
    type = lib.types.attrs.lazy (lib.types.submodule ({ config, name }:
      let
        input = {
          inherit name;
          inherit (config) src loader settings;
        };

        matching = builtins.filter
          (loader: input.loader == loader.name)
          loaders;

        first = builtins.head matching;

        loader =
          if builtins.length matching == 0 then
            null
          else if builtins.length matching > 1 then
            builtins.trace "[🍦 Nilla] ⚠️ Warning: Multiple loaders found for input \"${name}\", using first available: \"${first.name}\"" first
          else first;

        settings =
          if !(builtins.isNull loader) && loader.settings.type.check input.settings then
            input.settings
          else
            null;

        validity =
          if builtins.isNull loader then
            {
              message = "No loader found for input \"${name}\" with loader \"${input.loader}\".";
            }
          else if builtins.isNull settings then
            {
              message = "Invalid settings for loader \"${loader.name}\".";
            }
          else
            null;

        result =
          if builtins.isNull validity then
            loader.load input
          else
            null;
      in
      {
        options = {
          src = lib.options.create {
            description = "The source directory for this input.";
            type = lib.types.either lib.types.derivation lib.types.path;
          };

          loader = lib.options.create {
            description = "The loader to use to load this input from its source.";
            type = lib.types.string;
            default.value =
              let
                contents = builtins.readDir config.src;
                files = lib.attrs.filter (name: value: value == "regular") contents;
                directories = lib.attrs.filter (name: value: value == "directory") contents;
                symlinks = lib.attrs.filter (name: value: value == "symlink") contents;

                matching = builtins.filter
                  (loader: loader.check input)
                  customLoaders;
                loader = builtins.head matching;
              in
              if builtins.length matching != 0 then
                loader.name
              else if files ? "nilla.nix" then
                "nilla"
              else if files ? "default.nix" && directories ? "pkgs" && directories ? "lib" && symlinks ? ".version" then
                "nixpkgs"
              else if files ? "flake.nix" then
                "flake"
              else if files ? "default.nix" then
                "legacy"
              else
                "raw";
          };

          settings = lib.options.create {
            description = "Additional configuration to use when loading this input.";
            type = loader.settings.type;
            default.value = loader.settings.default;
          };

          valid = lib.options.create {
            description = "Whether or not this input is invalid, along with a message.";
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
                  "Input \"${name}\" failed to load due to either invalid settings or an invalid loader.";
              };
          };

          result = lib.options.create {
            description = "The loaded form of this input.";
            type = lib.types.raw;
            writable = false;
            default.value = result;
          };
        };
      })
    );
  };

  config = {
    assertions = lib.attrs.mapToList
      (name: input: {
        assertion = input.valid.value;
        message = input.valid.message;
      })
      cfg;
  };
}
