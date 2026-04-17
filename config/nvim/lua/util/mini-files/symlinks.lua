-- Symlink indicators for mini.files (async)

local api = vim.api
local ns = api.nvim_create_namespace("mini_files_symlinks")
local uv = vim.uv

local function markSymlinks(buf_id)
  api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
  local MiniFiles = require("mini.files")
  local nlines = api.nvim_buf_line_count(buf_id)

  for i = 1, nlines do
    local entry = MiniFiles.get_fs_entry(buf_id, i)
    if not entry then break end

    local line_idx = i - 1
    local path = entry.path
    local name = entry.name

    uv.fs_lstat(path, function(err, stat)
      if err or not stat or stat.type ~= "link" then return end
      vim.schedule(function()
        if not api.nvim_buf_is_valid(buf_id) then return end

        api.nvim_buf_set_extmark(buf_id, ns, line_idx, 0, {
          sign_text = "↩",
          sign_hl_group = "MiniDiffSignDelete",
          priority = 1,
        })

        local line = api.nvim_buf_get_lines(buf_id, line_idx, line_idx + 1, false)[1]
        if not line then return end
        -- Skip the leading /NNN/icon / path prefix that mini.files prepends
        local _, prefix_end = line:find("^/%d+/.-/")
        if not prefix_end then return end
        local nameStart = line:find(vim.pesc(name), prefix_end + 1)
        if nameStart then
          api.nvim_buf_set_extmark(buf_id, ns, line_idx, nameStart - 1, {
            end_col = nameStart + #name - 1,
            hl_group = "MiniDiffSignDelete",
          })
        end
      end)
    end)
  end
end

local M = {}

function M.setup()
  local group = api.nvim_create_augroup("MiniFiles_symlinks", { clear = true })

  api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniFilesBufferUpdate",
    callback = function(args)
      markSymlinks(args.data.buf_id)
    end,
  })
end

return M
