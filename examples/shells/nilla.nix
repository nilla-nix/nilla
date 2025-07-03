let
  nilla = import ../../default.nix;

  result =
    nilla.create ({ inputs }: {
      config = {
        inputs = {
          nixpkgs = {
            src = builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
              sha256 = "sha256-VljtYzyttmvkWUKTVJVW93qAsJsrBbgAzy7DdnJaQfI=";
            };
          };
        };

        shells.default = {
          systems = [ "x86_64-linux" ];

          builder = "nixpkgs";

          settings = {
            pkgs = inputs.nixpkgs;

            args = { };

          };

          shell = { mkShell, hello, ... }:
            mkShell {
              packages = [ hello ];
            };
        };
      };
    });
in
result
