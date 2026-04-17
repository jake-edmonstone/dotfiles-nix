{ config, ... }:

{
  xdg.configFile = {
    "sioyek/keys_user.config".source = ../config/sioyek/keys_user.config;
    "sioyek/prefs_user.config".source = ../config/sioyek/prefs_user.config;
  };

  # Sioyek on macOS reads from ~/Library/Application Support/sioyek/,
  # not the XDG path. Redirect via symlink so the XDG configs are used.
  # (Module is only imported from home/darwin.nix, so no platform guard needed.)
  home.file."Library/Application Support/sioyek".source =
    config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sioyek";
}
