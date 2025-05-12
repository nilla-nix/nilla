let
  root = ../../.;

  nilla = import "${root}/default.nix";

  result =
    nilla.create ({ lib, config }: {
      config = {
        inputs = {
          dep = {
            src = "${root}/examples/nilla/dep";
            settings = {
              extend = {
                modules = [
                  {
                    config.inputs.nixpkgs.src = lib.modules.overrides.force (builtins.fetchTarball {
                      url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
                      sha256 = "sha256-3e+AVBczosP5dCLQmMoMEogM57gmZ2qrVSrmq9aResQ=";
                    });
                  }
                ];
              };
            };
          };
        };

        shells.default =
          config.inputs.dep.result.shells.default;
      };
    });
in
result
