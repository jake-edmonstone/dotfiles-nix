-- Chezmoi-aware icon resolution for mini.files
-- Uses content.prefix to resolve chezmoi names to target icons.

local chezmoi = require("util.chezmoi")
local MiniFiles, MiniIcons

local function prefix(fs_entry)
  if not MiniFiles then
    MiniFiles = require("mini.files")
    MiniIcons = _G.MiniIcons
  end

  if not MiniIcons or not chezmoi.is_source_path(fs_entry.path) then
    return MiniFiles.default_prefix(fs_entry)
  end

  local category = fs_entry.fs_type == "directory" and "directory" or "file"
  local target = chezmoi.to_target_name(fs_entry.name)
  local icon, hl = MiniIcons.get(category, target)
  return icon .. " ", hl
end

return { prefix = prefix }
