-- Chezmoi naming convention utilities
-- Shared by mini-files icon prefix and global MiniIcons wrapper.

local chezmoi_source = vim.env.HOME .. "/.local/share/chezmoi"

-- Chezmoi attribute prefixes (longer compound prefixes first for greedy match)
local ordered_prefixes = {
  "run_onchange_after_", "run_onchange_before_", "run_onchange_",
  "run_once_after_", "run_once_before_", "run_once_",
  "run_after_", "run_before_", "run_",
  "create_", "empty_", "encrypted_", "exact_", "executable_", "external_",
  "modify_", "once_", "private_", "readonly_", "remove_", "symlink_",
}

local prefix_lengths = {}
for i, p in ipairs(ordered_prefixes) do
  prefix_lengths[i] = #p
end

local find = string.find
local sub = string.sub
local byte = string.byte

-- First bytes that can start a chezmoi attribute prefix
-- c=99 e=101 m=109 o=111 p=112 r=114 s=115
local prefix_start = {
  [99] = true, [101] = true, [109] = true, [111] = true,
  [112] = true, [114] = true, [115] = true,
}

local M = {}

M.source = chezmoi_source

--- Strip chezmoi naming conventions to get the target filename.
--- e.g. "dot_zshrc.tmpl" -> ".zshrc", "exact_dot_config" -> ".config"
function M.to_target_name(name)
  local len = #name
  local b1 = byte(name, 1)

  -- Fast path: first byte can't start any attribute prefix
  if not prefix_start[b1] then
    -- Might still have dot_, literal_, or suffixes
    if b1 == 100 and find(name, "dot_", 1, true) == 1 then -- d
      name = "." .. sub(name, 5)
      len = len - 3
    elseif b1 == 108 and find(name, "literal_", 1, true) == 1 then -- l
      name = sub(name, 9)
      len = len - 8
    end
    if len > 5 and sub(name, len - 4) == ".tmpl" then
      name = sub(name, 1, len - 5)
      len = len - 5
    end
    if len > 8 and sub(name, len - 7) == ".literal" then
      name = sub(name, 1, len - 8)
    end
    return name
  end

  -- Slow path: potential attribute prefix(es)
  local changed = true
  while changed do
    changed = false
    for i = 1, #ordered_prefixes do
      if find(name, ordered_prefixes[i], 1, true) == 1 then
        name = sub(name, prefix_lengths[i] + 1)
        changed = true
        break
      end
    end
  end
  if find(name, "dot_", 1, true) == 1 then
    name = "." .. sub(name, 5)
  end
  if find(name, "literal_", 1, true) == 1 then
    name = sub(name, 9)
  end
  len = #name
  if len > 5 and sub(name, len - 4) == ".tmpl" then
    name = sub(name, 1, len - 5)
    len = len - 5
  end
  if len > 8 and sub(name, len - 7) == ".literal" then
    name = sub(name, 1, len - 8)
  end
  return name
end

--- Check if a path is inside the chezmoi source directory.
function M.is_source_path(path)
  return find(path, chezmoi_source, 1, true) == 1
end

return M
