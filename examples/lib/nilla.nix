let
  nilla = import ../../default.nix;
in
nilla.create {
  config = {
    lib.examples.hello-world = "Hello, world!";
  };
}
