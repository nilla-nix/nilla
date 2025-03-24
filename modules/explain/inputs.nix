{ config, lib }:
{
  config.explain.inputs = {
    name = "Inputs";
    description = "Inputs are dependencies which are loaded into the Nilla project.";

    data = {
      columns = [ "Name" "Loader" ];
      rows = lib.attrs.mapToList
        (name: input: [ name input.loader ])
        config.inputs;
    };
  };
}
