{ lib }:
{
  config = {
    loaders.raw = {
      settings = {
        type = lib.types.attrs.any;

        default = { };
      };

      load = input:
        input.src;
    };
  };
}
