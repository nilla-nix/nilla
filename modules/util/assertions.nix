{ lib }:
{
  options.assertions = lib.options.create {
    description = "A list of assertions to check against in order for the evaluation to succeed.";
    default.value = [ ];
    type = lib.types.list.of (lib.types.submodules.of {
      shorthand = true;
      modules = [
        {
          options = {
            assertion = lib.options.create {
              description = "The assertion to check against.";
              type = lib.types.bool;
            };

            message = lib.options.create {
              description = "The message to display if the assertion fails.";
              type = lib.types.string;
            };
          };
        }
      ];
    });
  };
}
