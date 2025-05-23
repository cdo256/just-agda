{
  flake.lib = rec {
    makeOverridable =
      f: origArgs:
      (f origArgs)
      // {
        override = newArgs: makeOverridable f (origArgs // newArgs);
      };
  };
}
