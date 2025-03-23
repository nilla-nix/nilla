let
	nilla = import (builtins.fetchTarball {
		url = "https://github.com/jakehamilton/nilla/archive/main.tar.gz";
		sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
	});

	module = { config, lib }:
		let
			pkgs = config.inputs.nixpkgs.result;
		in
		{
			config = {
				inputs = {
					nixpkgs = {
						src = builtins.fetchTarball {
							url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
							sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
						};
						target = "default.nix";
						settings = {
							system = "x86_64-linux";
						};
					};

					my-nilla-input = {
						src = builtins.fetchTarball {
							url = "https://github.com/jakehamilton/example/archive/main.tar.gz";
							sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
						};
						target = "nilla.nix";
						settings = { config }: {
							config.inputs.nixpkgs = config.inputs.nixpkgs.override {
								url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
							sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
							};
						};
					};

					my-flake-input = {
						src = builtins.fetchTarball {
							url = "https://github.com/jakehamilton/example/archive/main.tar.gz";
							sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
						};
						target = "flake.nix";
						settings = {
							inputs.nixpkgs = config.inputs.nixpkgs;
						};
					};

					my-raw-input = {
						src = builtins.fetchTarball {
							url = "https://github.com/jakehamilton/example/archive/main.tar.gz";
							sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
						};
					};
				};

				outputs = {
					packages = {
						x86-64_linux = {
							hello = pkgs.hello;
						};
					};

					systems = {
						bismuth = import "${pkgs}/lib/eval-config.nix" {
							inherit pkgs;
							modules = [ ./systems/bismuth/configuration.nix ];
						};
					};

					overlays = {
						example = final: prev: {
							hello2 = prev.hello;
						};
					};
				};
			};
		};
in
	nilla.create module
