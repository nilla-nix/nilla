{ lib }:
{
  options.modules = lib.options.create {
    description = "Modules which are available from this Nilla project.";
    type = lib.types.attrs.of (lib.types.attrs.of lib.types.raw);
    default.value = { };
  };
}
