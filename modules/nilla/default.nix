{ lib }:
{
  options.nilla = {
    version = lib.options.create {
      description = "The version of Nilla used.";
      type = lib.types.string;
      writable = false;
      default.value = "0.0.0-alpha.3";
    };
  };
}
