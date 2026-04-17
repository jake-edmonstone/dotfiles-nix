{ lib, pkgs, ... }:

let
  # ~/.bashrc is managed by install.sh as a REAL file (not via programs.bash).
  # Reason: home-manager would write it as a symlink into /nix/store, which on
  # rootless Nix isn't accessible at SSH login — the symlink would dangle and
  # bash couldn't read it, so the exec-into-chroot bootstrap would never fire.
  # install.sh's bootstrap ~/.bashrc sources ~/.bashrc.extra if present — we
  # materialize it here with Cerebras-specific env so it's a real file too,
  # readable before entering the chroot.
  bashrcExtraCerebras = pkgs.writeText "bashrc-extra-cerebras" ''
    # Managed by home-manager (home/cerebras.nix). Cerebras-specific env.
    if [[ $- == *i* ]]; then
      # Interactive: put Cerebras's cbrun on PATH.
      export PATH="/cb/tools/cerebras/cbrun/v0.3.3:$PATH"
    else
      # Non-interactive (ssh host cmd, cron, etc.): source the full Cerebras env.
      global_bashrc="/cb/user_env/bashrc-latest"
      [ -r "$global_bashrc" ] && . "$global_bashrc"
    fi
  '';
in

{
  imports = [
    ./common.nix
  ];

  home.username = "jakee";
  home.homeDirectory = "/cb/home/jakee";

  home.activation.writeBashExtra = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cat ${bashrcExtraCerebras} > "$HOME/.bashrc.extra"
  '';
}
