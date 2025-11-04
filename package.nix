{
  pkgs,
  agda2-mode ? pkgs.emacsPackages.agda2-mode,
  ...
}:
let
  inherit (pkgs) emacsPackagesFor;
  init-file = pkgs.stdenv.mkDerivation {
    name = "init.el";
    src = ./init.el;
    phases = [ "installPhase" ];
    installPhase = ''
      cp $src $out
    '';
  };
  emacs = (emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [
    agda2-mode
    epkgs.all-the-icons
    epkgs.all-the-icons-dired
    epkgs.closql
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
    epkgs.emacsql
    epkgs.evil
    epkgs.evil-collection
    epkgs.evil-embrace
    epkgs.evil-surround
    epkgs.forge
    epkgs.general
    epkgs.ghub
    epkgs.helpful
    epkgs.ivy
    epkgs.ivy-prescient
    epkgs.ivy-rich
    epkgs.lsp-ivy
    epkgs.lsp-mode
    epkgs.lsp-treemacs
    epkgs.lsp-ui
    epkgs.magit
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
wrapped
