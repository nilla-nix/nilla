{ lib }:
{
  config = {
    loaders.nixpkgs = {
      settings = {
        type = lib.types.submodules.of {
          shorthand = true;
          modules = [
            {
              options = {
                systems = lib.options.create {
                  description = "The system to build the package set for.";
                  type = lib.types.list.required lib.types.string;
                  default.value = [
                    # NOTE: These systems are defaulted to the ones that Nixpkgs specifies as
                    # `lib.systems.flakeExposed`. They may need to be modified in the future.
                    "x86_64-linux"
                    "aarch64-linux"
                    "x86_64-darwin"
                    "armv6l-linux"
                    "armv7l-linux"
                    "i686-linux"
                    "aarch64-darwin"
                    "powerpc64le-linux"
                    "riscv64-linux"
                    "x86_64-freebsd"
                  ];
                };

                overlays = lib.options.create {
                  description = "A list of overlays to apply to the package set.";
                  type = lib.types.list.of (lib.types.function lib.types.raw);
                  default.value = [ ];
                };

                # NOTE: We can't call this `config` due to that being a reserved word in the module
                # system. It's not pretty, but it works.
                configuration = lib.options.create {
                  description = "Configuration to apply to the package set.";
                  type = lib.types.attrs.any;
                  default.value = { };
                };
              };
            }
          ];
        };

        default = { };
      };

      load = input:
        let
          pkgs =
            lib.attrs.generate
              input.settings.systems
              (system:
                import input.src {
                  inherit system;
                  inherit (input.settings) overlays;
                  config = input.settings.configuration;
                }
              );
        in
        pkgs // {
          lib = import "${input.src}/lib";
        };
    };
  };
}
