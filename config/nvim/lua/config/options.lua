vim.g.snacks_animate = false

-- reload files changed outside nvim
vim.o.autoread = true
vim.o.winborder = "rounded"
vim.o.pumborder = "rounded"
-- hide whitespace indicators (LazyVim enables list by default)
vim.o.list = false
vim.o.number = true
vim.o.relativenumber = false
vim.o.swapfile = false
vim.o.clipboard = "unnamedplus"

-- blinking block in normal, blinking bar in insert, horizontal in replace
vim.o.guicursor =
  "n-v-c-sm:block-blinkwait700-blinkon400-blinkoff250,i-ci-ve:ver25-blinkwait700-blinkon400-blinkoff250,r-cr-o:hor20"

vim.g.root_spec = { "cwd" } -- use cwd as root, not git repo

-- load built-in undo tree visualizer
vim.cmd.packadd("nvim.undotree")
