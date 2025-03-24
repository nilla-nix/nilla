{ lib }:
{
  config = {
    loaders.nilla = {
      settings = {
        type = lib.types.submodule {
          options = {
            target = lib.options.create {
              description = "The relative path to the file to load.";
              type = lib.types.string;
              default.value = "nilla.nix";
            };

            extend = lib.options.create {
              description = "Arguments to pass to the function which is loaded.";
              type = lib.types.any;
              default.value = { };
            };
          };
        };

        default = { };
      };

      load = input:
        let
          value = import "${input.src}/${input.settings.target}";

          result =
            if input.settings.extend == { } then
              value
            else
              let
                customized = value.extend input.settings.extend;
              in
              customized.config // {
                extend = customized.extend;
              };
        in
        if
          !(builtins.isAttrs result)
          || !(result ? extend)
          || !(result ? nilla)
          || !(result.nilla ? version)
        then
          builtins.throw "[🍦 Nilla] Failed to load a valid Nilla project from source \"${input.src}\"."
        else
          result;
    };
  };
}
