return {
  {
    "nvim-mini/mini.files",
    dependencies = { "nvim-mini/mini.icons" },
    init = function()
      -- Load eagerly when neovim opens a directory (nvim .)
      if vim.fn.argc(-1) > 0 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("mini.files")
        end
      end
      -- Close mini.files when a Snacks picker opens to avoid floating window conflicts
      local group = vim.api.nvim_create_augroup("MiniFilesSnacksFix", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "snacks_picker_input",
        callback = function()
          local ok, MiniFiles = pcall(require, "mini.files")
          if ok then
            MiniFiles.close()
          end
        end,
      })
    end,
    config = function(_, opts)
      local chezmoi_mf = require("util.mini-files.chezmoi")
      opts.content = { prefix = chezmoi_mf.prefix }
      require("mini.files").setup(opts)
      require("util.mini-files.git").setup()
      require("util.mini-files.symlinks").setup()

      -- Override .tmpl extension so chezmoi templates get correct syntax in previews.
      -- O(1) extension hash lookup — only fires for .tmpl files, no broad patterns.
      local chezmoi_source = require("util.chezmoi").source
      local chezmoi_target = require("util.chezmoi").to_target_name
      vim.filetype.add({
        extension = {
          tmpl = function(path)
            if path and path:find(chezmoi_source, 1, true) == 1 then
              local target = chezmoi_target(path:match("[^/]+$") or path)
              local ft = vim.filetype.match({ filename = target })
              return ft and (ft .. ".chezmoitmpl") or "chezmoitmpl"
            end
            return "template"
          end,
        },
      })
    end,
    opts = {
      options = { use_as_default_explorer = true },
      mappings = {
        close = "q",
        go_in = "<Tab>",
        go_in_plus = "<Enter>",
        go_out = "-",
        go_out_plus = "",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },
    },
    keys = {
      {
        "<leader>o",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            local buf_name = vim.api.nvim_buf_get_name(0)
            if buf_name == "" or not vim.uv.fs_stat(buf_name) then
              buf_name = vim.uv.cwd() --[[@as string]]
            end
            MiniFiles.open(buf_name, true)
          end
        end,
        desc = "Toggle mini.files (Directory of Current File)",
      },
      {
        "<leader>O",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            MiniFiles.open(vim.uv.cwd(), true)
          end
        end,
        desc = "Toggle mini.files (cwd)",
      },
    },
  },
}
