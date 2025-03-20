let
  pins = import ./npins;

  lib = import "${pins.labs}/lib";
in
{
  create = module:
    let
      result =
        lib.modules.run {
          modules =
            (import ./modules)
            ++ (lib.lists.from.any module)
            ++ [
              # We add the Lib module here so that we can use `lib` directly from its source to handle
              # the merges rather than using the module argument which can result in recursion issues.
              {
                __file__ = "virtual:nilla/lib";

                options = {
                  lib = lib.options.create {
                    type = lib.types.attrs.any;
                    default.value = { };
                    description = "An attribute set of values to be added to `lib`.";
                    apply = value: lib.extend (final: prev: lib.attrs.mergeRecursive prev value);
                  };
                };
              }
            ];
        };

      config = result.config;

      withWarnings = value:
        let
          logged = builtins.map
            (item:
              builtins.trace
                "[🍦 Nilla] ⚠️ Warning: ${item}"
                null
            )
            config.warnings;
        in
        builtins.deepSeq
          logged
          value;

      assertions = builtins.filter (item: !item.assertion) config.assertions;

      failure =
        let
          formatted = builtins.map
            (item:
              "[🍦 Nilla] ❌ Assertion: ${item.message}"
            )
            assertions;
        in
        # Some assertions failed! Take a look at the end of the log for more information.
        builtins.throw "\n\n${builtins.concatStringsSep "\n" formatted}";

      resolved =
        if builtins.length assertions > 0 then
          builtins.addErrorContext "[🍦 Nilla] Some assertions failed!"
            failure
        else
          result;
    in
    withWarnings resolved;
}
