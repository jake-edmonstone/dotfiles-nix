{
  config,
  lib,
  ...
}:

{
  imports = [ ../../home/linux.nix ];

  home = {
    username = "jedmonstone";
    homeDirectory = "/home/STRIKETECH/jedmonstone";
  };

  programs = {
    git = {
      settings.user = {
        name = "Jake Edmonstone";
        email = "jedmonstone@striketechnologies.com";
      };
      includes = [
        {
          condition = "gitdir:${config.home.homeDirectory}/nix-config/";
          contents.user = {
            name = "jake-edmonstone";
            email = "jbedmonstone@gmail.com";
          };
        }
      ];
    };

    # The GTS machine has no local graphical session. Keep Tinymist available
    # for editing while preventing typst-preview.nvim from launching a browser.
    neovim.initLua = lib.mkBefore ''
      vim.g.headless_server = true
    '';
  };
}
