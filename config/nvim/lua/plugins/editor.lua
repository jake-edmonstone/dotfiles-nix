return {
  { "folke/persistence.nvim", enabled = false },

  -- Resolve chezmoi-named files to their target icons globally
  {
    "nvim-mini/mini.icons",
    config = function(_, opts)
      require("mini.icons").setup(opts)
      require("mini.icons").mock_nvim_web_devicons()
      local chezmoi = require("util.chezmoi")
      local orig = MiniIcons.get
      local source = chezmoi.source
      local find = string.find
      local match = string.match
      local to_target = chezmoi.to_target_name
      MiniIcons.get = function(category, name) ---@diagnostic disable-line: duplicate-set-field
        if category == "file" or category == "directory" then
          -- Only transform chezmoi source paths (99%+ of calls skip instantly)
          if find(name, source, 1, true) == 1 then
            local basename = match(name, "[^/]+$") or name
            local target = to_target(basename)
            if target ~= basename then
              return orig(category, target)
            end
          else
            -- Bare basename with chezmoi prefix (e.g. from devicons shim)
            local target = to_target(name)
            if target ~= name then
              return orig(category, target)
            end
          end
        end
        return orig(category, name)
      end
    end,
  },

  {
    "nvim-mini/mini.ai",
    opts = {
      mappings = {
        around_next = "", -- free an for builtin treesitter node selection
        inside_next = "", -- free in for builtin treesitter node selection
      },
    },
  },

  {
    "folke/noice.nvim",
    opts = { presets = { lsp_doc_border = true } },
  },

  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      styles = {
        win = { border = "rounded" },
        news = { border = "rounded" },
        lazygit = { border = "rounded" },
      },
      picker = {
        win = { preview = { wo = { wrap = true } } },
        sources = {
          files = { hidden = true },
          explorer = { layout = { layout = { position = "right" } } },
        },
        layout = { preset = "default" },
        hidden = true,
      },
    },
  },

  {
    "pwntester/octo.nvim",
    opts = { use_local_fs = true },
  },

  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = vim.o.timeoutlen,
      default_mappings = false,
      mappings = {
        i = {
          j = { k = "<Esc>" },
          k = { j = "<Esc>" },
        },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = { left = "", right = "" }, -- pipe separator character: │
        section_separators = "",
      },
      sections = {
        lualine_c = {
          { "diagnostics" },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { LazyVim.lualine.pretty_path({ modified_sign = " ●", modified_hl = "LualineModified" }) },
        },
        lualine_x = { { "lsp_status" } },
        lualine_z = {},
      },
    },
  },

  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Navigate left (tmux)" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Navigate down (tmux)" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Navigate up (tmux)" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Navigate right (tmux)" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Navigate previous (tmux)" },
    },
  },
}
