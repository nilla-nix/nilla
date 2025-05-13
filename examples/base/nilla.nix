let
  pins = import ../../npins;
  nilla = import ../../default.nix;

  result =
    nilla.create {
      config = {
        inputs = {
          nixpkgs = {
            src = pins.nixpkgs;
          };
        };
      };
    };
in
result
