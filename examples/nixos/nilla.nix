let
  nilla = import ../../default.nix;

  result =
    nilla.create {
      config = {
        inputs = {
          nixpkgs = {
            src = builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
              sha256 = "065n9ik9c1xi7na6vcr2m5j6a3ws83l58mpwpkn120jq2ccr05qs";
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
