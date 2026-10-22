.DEFAULT_GOAL := help

ARGS ?=

.PHONY: build switch test boot diff repl check fmt lint update

build:
	nixos-rebuild build --flake . $(ARGS)

switch:
	nixos-rebuild switch --sudo --flake . $(ARGS)

test:
	nixos-rebuild test --sudo --flake . $(ARGS)

boot:
	nixos-rebuild boot --sudo --flake . $(ARGS)

check:
	nix flake check $(ARGS)

fmt:
	nix fmt

lint:
	nix run nixpkgs#statix -- check .
	nix run nixpkgs#deadnix -- --fail .

update:
	nix flake update
