# Using Borg in your configuration

Add to `~/config/flake.nix`:

```nix
inputs.borg = {
  url = "path:/home/jx/code/misc/borg";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

In a NixOS module receiving `inputs` and `pkgs`:

```nix
environment.systemPackages = [
  inputs.borg.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

For Home Manager, use `home.packages` instead. Pass `inputs` through
`specialArgs = { inherit inputs; };` in `nixosSystem`, or `extraSpecialArgs`
in standalone `homeManagerConfiguration`. Include `inputs` in your flake's
outputs arguments, for example `outputs = inputs@{ nixpkgs, ... }: ...`.

Remove any existing Borg package entry to avoid executable collisions.
The shared nixpkgs input must be sufficiently recent for Borg's dependencies.

After changing the Borg source, refresh the lock and rebuild your configuration:

```sh
nix flake update
nixos-rebuild switch --flake .
```
