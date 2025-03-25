let
  nilla = import ../../default.nix;

  result =
    nilla.create {
      config = {
        inputs = {
          nixpkgs = {
            src = builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
              sha256 = "013q5l72i020y3b7sdw1naiqwxm4h29alwlzkv4jsnb2k7qmwbdf";
            };
          };

          plusultra = {
            src = builtins.fetchTarball {
              url = "https://github.com/jakehamilton/config/archive/main.tar.gz";
              sha256 = "1z50qmmc2hnqjc53cpaijxn16dlyyx5iglvi3xwri4j8dwg98fnc";
            };
          };
        };
      };
    };
in
result
