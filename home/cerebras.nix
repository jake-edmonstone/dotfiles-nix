{ ... }:

{
  imports = [
    ./common.nix
  ];

  home.username = "jakee";
  home.homeDirectory = "/cb/home/jakee";

  # Bash is the sysadmin-forced login shell; it immediately execs into zsh.
  # (We can't `chsh`, hence the bash → zsh hop.)
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Source global definitions
      if [ -f /etc/bashrc ]; then
        . /etc/bashrc
      fi

      # Full Cerebras env for non-interactive shells (cbrun remotes, scripts);
      # fast path for interactive (just cbrun on PATH, then exec zsh).
      if [[ $- == *i* ]]; then
        export PATH="/cb/tools/cerebras/cbrun/v0.3.3:$PATH"
      else
        global_bashrc="/cb/user_env/bashrc-latest"
        [ -r "$global_bashrc" ] && . "$global_bashrc"
      fi

      # Switch interactive shells to zsh. When rootless Nix is installed,
      # enter the user-namespace chroot directly here so zsh starts with
      # /nix/store already visible (saves a second exec hop in zshrc).
      if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
        if [ -x "$HOME/.local/bin/nix-user-chroot" ] && [ -d "$HOME/.nix" ]; then
          export NIX_USER_CHROOT=1
          exec "$HOME/.local/bin/nix-user-chroot" "$HOME/.nix" /usr/bin/env zsh -l
        fi
        exec /usr/bin/zsh -l
      fi
    '';
  };
}
