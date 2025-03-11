{ lib }:
{
  options.warnings = lib.options.create {
    description = "A list of warnings to display after evaluating modules.";
    default.value = [ ];
    type = lib.types.list.of lib.types.string;
  };
}
