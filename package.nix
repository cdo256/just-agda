{ pkgs, replaceVars, ... }:
let
  init-file = pkgs.stdenv.mkDerivation {
    name = "init.el";
    src = replaceVars ./init.el { };
    phases = [ "installPhase" ];
    installPhase = ''
      cp $src $out
    '';
  };
  wrapped = pkgs.writeShellScriptBin "just-agda" ''
    CONFIG_DIR="''${XDG_CONFIG_HOME:-''$HOME/.config}/just-agda"
    mkdir -p $CONFIG_DIR
    rm -f $CONFIG_DIR/init.el
    ln -s ${init-file} $CONFIG_DIR/init.el
    ${pkgs.emacs}/bin/emacs --init-directory $CONFIG_DIR "$@"
  '';
in
# See nix Cookbook.
pkgs.symlinkJoin {
  name = "just-agda";
  paths = [
    pkgs.emacs
    (pkgs.agda.withPackages (ps: [
      ps.standard-library
    ]))
    wrapped
  ];
  buildInputs = [ ];
}
