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

            loader = "legacy";

            settings = {
              args = {
                system = "x86_64-linux";
              };
            };
          };
        };

        systems.nixos.mysystem = {
          modules = [{
            boot.loader.grub.devices = [ "/dev/sda" ];
            fileSystems = {
              "/" = {
                device = "/dev/sda1";
              };
            };
          }];
        };
      };
    };
in
result
