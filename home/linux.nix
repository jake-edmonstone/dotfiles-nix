{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./common.nix ];

  targets.genericLinux = {
    enable = true;
    # This profile is used on a headless server; do not wrap GUI programs in
    # nixGL or pull in graphics-driver integration.
    gpu.enable = false;
  };

  home.packages = with pkgs; [
    clang-tools
    trash-cli
  ];

  programs = {
    home-manager.enable = true;
    lazygit.enableBashIntegration = false;

    bash = {
      enable = true;
      # bashrcExtra runs before Home Manager's interactive-shell guard, so SSH
      # commands retain AlmaLinux's setup and can find the Nix profile without
      # being replaced by Fish.
      bashrcExtra = ''
        if [[ -r /etc/bashrc ]]; then
          source /etc/bashrc
        fi
        source ${pkgs.nix}/etc/profile.d/nix.sh
        source ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh

        if [[ -d "$HOME/.bashrc.d" ]]; then
          for rc in "$HOME"/.bashrc.d/*; do
            [[ -f "$rc" ]] && source "$rc"
          done
          unset rc
        fi
      '';

      initExtra = lib.mkOrder 3000 ''
        # Keep the directory-managed login shell unchanged, but replace
        # interactive Bash with Fish. A Bash subshell launched from Fish stays
        # in Bash instead of immediately looping back.
        if [[ $- == *i* && -z ''${BASH_EXECUTION_STRING:-} ]]; then
          parent_command="$(ps -o comm= -p "$PPID" | tr -d '[:space:]')"
          if [[ "$parent_command" != fish ]]; then
            exec ${config.programs.fish.package}/bin/fish
          fi
          unset parent_command
        fi
      '';
    };
  };
}
