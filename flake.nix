{
  description = "leJeuDeTrictracRenduFacile";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        # let pkgs = nixpkgs.legacyPackages.${system}; in
        let pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        }; in
        {
          devShell = import ./nixfiles/shell.nix { inherit pkgs; };
        }
      );
}

