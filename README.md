<img src="https://raw.githubusercontent.com/nilla-nix/art/main/nilla-banner.svg" width="100%" alt="Nilla">

> Nilla is a simple-to-use, easy-to-extend Nix framework for managing projects.

| Feature              | Nilla    | Flakes     | Legacy |
| -------------------- | -------- | ---------- | ------ |
| Pinnable inputs      | ✔️       | ✔️         | ❌     |
| Input loaders        | ✔️       | ❌         | ❌     |
| Minimal boilerplate  | ✔️       | ❌         | ✔️     |
| Configurable inputs  | ✔️       | ❌         | ⚠️\*   |
| Extensible           | ✔️       | ❌         | ❌     |
| Lazy                 | ✔️       | ⚠️\*\*     | ✔️     |
| Available OOTB       | ✔️       | ❌         | ✔️     |
| Nixpkgs-agnostic     | ✔️       | ❌         | ✔️     |
| Type checked         | ✔️       | ❌         | ❌     |
| Configurable systems | ✔️       | ❌         | ❌     |
| Defined schema       | ✔️       | ✔️         | ❌     |
| Stable               | ⚠️\*\*\* | ⚠️\*\*\*\* | ✔️     |

⚠️\* Legacy configuration using `default.nix` and `shell.nix` can only accept dynamic values via function attributes during instantiation, dramatically limiting what can be modified by consumers of a project.

⚠️\*\* Flakes have a work-in-progress feature "Lazy Trees" which hopes to address its input laziness shortcoming. However, this feature is not yet available.

⚠️\*\*\* Nilla isn't stable... yet! We are moving towards a 1.0.0 stability guarantee, but for now it is expected that some things will be broken or change as development continues on pre-1.0 versions.

⚠️\*\*\*\* Flakes are widely used but remain an experimental feature of Nix subject to change.

## Why Nilla?

Nilla combines many of the lessons learned from working with Flakes, NixOS Modules, and Legacy `default.nix` files. Bringing the best qualities of these different strategies together in a modular fashion allows for much easier management of projects than before. Nilla gives you the schema guarantees of Flakes, but with the ability to extend or change that schema as you need. You get the type-checking and pluggability of NixOS Modules without a forced Nixpkgs import while also benefiting from some features like Portable Submodules. Finally, you have the ability to manage more than one system, package, shell, etc. easily, unlike with legacy `default.nix` and `shell.nix` approaches.

## How can I start using Nilla?

To get started, install the [Nilla CLI](https://github.com/nilla-nix/cli). While Nilla projects can be used with plain Nix commands, it is quite cumbersome. The Nilla CLI streamlines the process and even gives some added quality of life improvements to common experiences (such as hash mismatches during builds).

Once you have the Nilla CLI installed, you can create your first Nilla Project. Each Nilla Project is an entrypoint that provides everything you need for that project. This includes packages, shells, system configurations, or anything else you require! To create a Nilla project, make a `nilla.nix` file (typically at the root of your project) and import Nilla like the following example.

```nix
let
  nilla = import (builtins.fetchTarball {
    url = "https://github.com/nilla-nix/nilla/archive/main.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  });
in
nilla.create {
    # You will add your project's configuration here!
}
```

That is all you need for a base Nilla project! Though, an empty project configuration isn't too useful. To complete this example let's add a Nixpkgs input and declare a development shell.

```nix
let
  nilla = import (builtins.fetchTarball {
    url = "https://github.com/nilla-nix/nilla/archive/main.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  });
in
nilla.create {
  config = {
    inputs = {
      nixpkgs = {
        src = builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000";
        };

        # Nilla will auto-detect the loader, but for this example we will set it manually.
        loader = "nixpkgs";

        settings = {
            # The loaded form of this input will be for these systems. Then our packages,
            # shells, and other items can use these package sets.
            # By default this will be set to the same systems as Nixpkgs exposes for its flake interface.
            systems = [ "x86_64-linux" "aarch64-linux" ];
        };
      };
    };

    shells.default = {
      # Our shell will be available on each platform in the systems list.
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # Shell definitions are declared using Nixpkgs' callPackage convention by default.
      shell = { mkShell, hello, ... }:
        mkShell {
          packages = [
            # The `hello` package will be available in our development shell.
            hello
          ];
        };
    };
  };
}
```

Now that your project file contains your configuration, the following command can be used to start a development shell.

```shell
nilla shell
```

Try running the `hello` command once the development shell is open!

## How do I customize my configuration?

Nilla uses [Aux Lib](https://git.auxolotl.org/auxolotl/lib), a standalone library that provides many common Nix helpers as well as a module system implementation. This means that to create your own module options and configuration, you will be using this library. Thankfully, though, it is quite similar to Nixpkgs and the parts that are different are designed to be easily and quickly discoverable. All features of the library are grouped into namespaces which make the tools more approachable. For example, if you need to transform an attribute set into a list then you can use `lib.attrs.mapToList`.

To get started writing your own modules, it is a good idea to first familiarize yourself with some differences between the module system provided by Aux Lib and the one you may know from Nixpkgs. Here are some important highlights (note how many are just good quality of life improvements)!

- Module arguments are always dynamic and do not require `...`.
- To include additional modules you can use the attribute `includes` (unlike Nixpkgs' `imports`).
- To exclude certain modules you can use the attribute `excludes` (unlike Nixpkgs' `disabledModules`).
- Aux Lib's module system uses the `freeform` attribute of a module or submodule to declare the fallback type for dynamically assigned values (unlike Nixpkgs' `freeformType`).
- Module shorthand is now only possible in submodules which explicitly opt-in to the feature.
- Module arguments have been separated into `static` and `dynamic` attribute sets to make it clear which can change.
- Options are created using `lib.options.create` (unlike Nixpkgs' `lib.mkOption`).
- Types are grouped similarly to the rest of the library, meaning that an attribute set with any value and an attribute set of a specific kind of value are found at `lib.types.attrs.any` and `lib.types.attrs.of` respectively.

With some of these notes in mind, let's create our first module! This example module will add support for a new input type. Nilla supports inputs using Loaders which are responsible for preparing an input to be used in the project. Our module is going to take a new kind of input and load it so the rest of the project can consume it.

```nix
# hello-loader.nix
{ lib }:
{
  config.loaders.hello = {
    # Our simple loader won't take any customization into account.
    settings = {
      type = lib.types.attrs.any;
      default = {};
    };

    load = input:
      let
        text = builtins.readFile "${input.src}/hello.txt";
      in
        # Loaders can return any form of data that they want. Typically this will be an attribute set,
        # but in this example we are going to load text from the input's `hello.txt` file directly.
        text;
  };
}
```

Now we can consume our new module in our project by adding it to our list of `includes`.

```nix
# nilla.nix
let
  nilla = import (builtins.fetchTarball {
    url = "https://github.com/nilla-nix/nilla/archive/main.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  });
in
nilla.create ({ config }:
  let
    # Get the loaded input data!
    text = config.inputs.myinput.result;
  in
  {
    # Include our module in the project.
    includes = [ ./hello-loader.nix ];

    config = {
      inputs = {
        myinput = {
          # An input's source can be fetched, but in this simple example let's use a directory
          # located at `./my/input`.
          src = ./my/input;

          # Specify our loader's name so it is used.
          loader = "hello";
        };
      };
    };
})
```

## What options are available out of the box?

While more options can be added in your project, here are the ones that Nilla provides by default. Note that all of the modules which declare these options can be disabled using `excludes` in your project if you want to do something another way!

### `nilla.version`

The version of Nilla used in this Project.

### `lib.*`

A customizable instance of Aux Lib. This is useful for creating helper functions which other modules can use.

### `inputs.<name>.src`

Set the source derivation for an input. This is typically fetched using `fetchTarball` inline or is taken from the output of a tool like [npins](https://github.com/andir/npins).

### `inputs.<name>.loader`

The name of the loader to use. By default, Nilla will look at the contents of your source and try to find an appropriate loader. However, it is best practice to set the loader to be the one you want to use.

### `inputs.<name>.settings`

Settings which can be applied to a loader. Each loader implements its own `settings` type, so the value may differ between different input types.

### `inputs.<name>.result`

The loaded form of the input. Each input may be loaded differently depending on which loader is used.

### `loaders.<name>.settings.type`

The settings type that is used to check and merge user-provided settings.

### `loaders.<name>.settings.default`

The default value to use for the settings. Typically, this is an empty attribute set.

### `loaders.<name>.load`

The function responsible for loading an input. This function takes an input in the shape of:

```
{
  src: Derivation,
  loader: String,
  settings: LoaderSettings,
}
```

### `builders.<name>.settings.type`

The settings type that is used to check and merge user-provided settings.

### `builders.<name>.settings.default`

The default value to use for the settings. Typically, this is an empty attribute set.

### `builders.<name>.build`

The function responsible for building a package. This function takes package in the shape of:

```
{
  systems: List<String>,
  builder: String,
  settings: LoaderSettings,
  package: (PackageArgs) -> Derivation,
}
```

### `packages.<name>.systems`

A list of systems which the package is built for.

### `packages.<name>.builder`

The name of the builder to use. By default, this is set to "nixpkgs", but another builder can be used if you prefer.

### `packages.<name>.settings`

Additional settings which are passed to the builder.

### `packages.<name>.package`

The package definition function. This function is expected to return a derivation.

### `packages.<name>.result.<system>`

The built package for each system is automatically created and set at this location. These are created by Nilla and are not writable.

### `shells.<name>.systems`

A list of systems which the shell is built for.

### `shells.<name>.builder`

The name of the builder to use. By default, this is set to "nixpkgs", but another builder can be used if you prefer.

### `shells.<name>.settings`

Additional settings which are passed to the builder.

### `shells.<name>.shell`

The shell definition function. This function is expected to return a derivation.

### `shells.<name>.result.<system>`

The built shell for each system is automatically created and set at this location. These are created by Nilla and are not writable.

## How can I contribute?

Firstly, thank you, because you already are! By giving Nilla a try you're helping to find its quirks. Sharing your feedback on the [Discussions Board](https://github.com/nilla-nix/nilla/discussions) is a great way to give back after taking Nilla for a test drive. If you have more time to spend helping with the project, then any of the following things are welcome pull requests:

- Improving CLI stability
- Adding missing CLI options
- Fixing bugs
- Making error messages more helpful / adding error messages where there should be some
- Adding support for the `macos` system type
- Experimenting with additional project features, such as `checks` to see if they should be added
- Missing functionality

A fair amount of this may seem vague, but that's okay! In this early stage of building Nilla there is still a lot of experimentation to be done. If you think of something that you believe would be good for Nilla, then please start a discussion!
