{ lib }:
let
  compat = builtins.fetchTarball {
    url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
    sha256 = "1zcwz5zcc3mccpaxp02sgbs27nrq4wgh2s0vij6vk23sgzh7jmi3";
  };
in
{
  config = {
    loaders.flake = {
      settings = {
        type = lib.types.submodule {
          options = {
            target = lib.options.create {
              description = "The relative path to the file to load.";
              type = lib.types.string;
              default.value = "flake.nix";
            };
          };
        };

        default = { };
      };

      load = input:
        let
          value = import compat { src = builtins.dirOf "${input.src}/${input.settings.target}"; };
        in
        value.defaultNix;
    };
  };
}
