{
  description = "BorgBackup";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }: {
    packages =
      nixpkgs.lib.genAttrs
        [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ]
        (system: {
          default = import ./default.nix { pkgs = nixpkgs.legacyPackages.${system}; };
        });
  };
}
