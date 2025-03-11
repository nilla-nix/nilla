let
  labs = builtins.fetchTarball {
    url = "https://git.auxolotl.org/auxolotl/labs/archive/feat/portable-submodules.tar.gz";
    sha256 = "054bc670lcpw3sdvb3qc338dv2594x95pzp2avx67g97h7dj1wmk";
  };

  lib = import "${labs}/lib";
in
{
  create = module:
    let
      result =
        lib.modules.run {
          modules =
            (import ./modules)
            ++ (lib.lists.from.any module);
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
