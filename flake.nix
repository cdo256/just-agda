{
  description = "Emacs with just Agda mode and practically nothing else.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    let
      inherit (inputs) self flake-parts;
      inherit (self.lib) makeOverridable;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (top: {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        ./lib.nix
      ];
      perSystem =
        { pkgs, ... }:
        let
          naryaPackage = pkgs.writeShellScriptBin "narya" ''
            set -euo pipefail

            root=/home/cdo/src/narya

            for candidate in \
              "$root/_build/install/default/bin/narya" \
              "$root/_build/default/bin/narya.exe"
            do
              if [ -x "$candidate" ]; then
                exec "$candidate" "$@"
              fi
            done

            exec ${pkgs.nix}/bin/nix develop "$root" --command ${pkgs.bash}/bin/bash -lc 'cd /home/cdo/src/narya && exec dune exec narya -- "$@"' bash "$@"
          '';
          naryaInstallPg = pkgs.writeShellScriptBin "narya-install-pg" ''
            set -euo pipefail
            cd /home/cdo/src/narya/dist
            exec ${pkgs.bash}/bin/bash ./install-pg.sh "$@"
          '';
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [
              pkgs.agda # For testing
              naryaPackage
              naryaInstallPg
            ];
          };
          packages = rec {
            narya = naryaPackage;
            narya-install-pg = naryaInstallPg;
            just-agda = makeOverridable (import ./package.nix) {
              inherit pkgs;
              narya = naryaPackage;
              naryaInstallPg = naryaInstallPg;
            };
            default = just-agda;
          };
        };
    });
}
