{
  pkgs,
  replaceVars,
  emacsPackagesFor,
  ...
}:
let
  agda = pkgs.agda.withPackages (ps: [ ps.standard-library ]);
  init-file = pkgs.stdenv.mkDerivation {
    name = "init.el";
    src = replaceVars ./init.el {
      inherit agda;
    };
    phases = [ "installPhase" ];
    installPhase = ''
      cp $src $out
    '';
  };
  emacs = (emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
    epkgs.agda2-mode
    epkgs.all-the-icons
    epkgs.all-the-icons-dired
    epkgs.command-log-mode
    epkgs.company
    epkgs.company-box
    epkgs.counsel
    epkgs.counsel-projectile
    #epkgs.dired
    epkgs.dired-hide-dotfiles
    epkgs.dired-open
    #epkgs.dired-single
    epkgs.doom-modeline
    epkgs.doom-themes
    epkgs.evil
    epkgs.evil-collection
    epkgs.general
    epkgs.helpful
    epkgs.ivy
    epkgs.ivy-prescient
    epkgs.ivy-rich
    epkgs.lsp-ivy
    epkgs.lsp-mode
    epkgs.lsp-treemacs
    epkgs.lsp-ui
    epkgs.no-littering
    epkgs.projectile
    epkgs.rainbow-delimiters
    epkgs.visual-fill-column
    epkgs.which-key
  ]);
  wrapped = pkgs.writeShellScriptBin "just-agda" ''
    CONFIG_DIR="''${XDG_CONFIG_HOME:-''$HOME/.config}/just-agda"
    mkdir -p $CONFIG_DIR
    rm -f $CONFIG_DIR/init.el
    ln -s ${init-file} $CONFIG_DIR/init.el
    ${emacs}/bin/emacs --init-directory $CONFIG_DIR "$@"
  '';
in
# See nix Cookbook.
pkgs.symlinkJoin {
  name = "just-agda";
  paths = [
    emacs
    wrapped
    agda
  ];
  buildInputs = [ agda ];
}
