return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "AI", mode = { "n", "v" } },
      },
    },
  },
  {
    -- Custom prompt builder (replaces conduit.nvim)
    dir = vim.fn.stdpath("config"),
    name = "prompt",
    keys = {
      { "<leader>ai", function() require("util.prompt").ask() end, desc = "Prompt" },
      { "<leader>ac", function() require("util.prompt").ask("@cursor: ") end, desc = "Prompt at cursor" },
      { "<leader>ab", function() require("util.prompt").ask("@buffer: ") end, desc = "Prompt about buffer" },
      { "<leader>ai", function() require("util.prompt").ask("@selection: ") end, mode = "v", desc = "Prompt about selection" },
      { "<leader>ad", function() require("util.prompt").ask("@diagnostic") end, desc = "Prompt about diagnostic" },
      { "<leader>ap", function() require("util.prompt").select_prompt() end, mode = { "n", "v" }, desc = "Select prompt" },
    },
  },
}
