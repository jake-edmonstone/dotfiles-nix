local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- build n×n of [] cells
local function grid_n(args)
  local n = tonumber(args[1][1]) or 1
  local nodes = {}
  for r = 1, n do
    local cells = {}
    for _ = 1, n do
      cells[#cells + 1] = "$$"
    end
    local line = "  " .. table.concat(cells, ", ")
    if r < n then
      nodes[#nodes + 1] = t({ line .. ",", "" })
    else
      nodes[#nodes + 1] = t({ line .. "," })
    end
  end
  return sn(nil, nodes)
end

local function grid_mn(args)
  local m = tonumber(args[1][1]) or 1 -- rows
  local n = tonumber(args[2][1]) or 1 -- cols
  local nodes = {}

  for r = 1, m do
    local cells = {}
    for _ = 1, n do
      cells[#cells + 1] = "$$"
    end
    local line = "  " .. table.concat(cells, ", ")
    if r < m then
      nodes[#nodes + 1] = t({ line .. ",", "" })
    else
      nodes[#nodes + 1] = t({ line .. "," })
    end
  end
  return sn(nil, nodes)
end

ls.add_snippets("typst", {
  -- preamble snippet
  s("pre", {
    t('#import "preamble.typ" : *'),
    t({ "", "#show: preamble" }),
  }),

  -- cayley table
  s("ctable", {
    t("#cayley-table("),
    i(1, "1"),
    t(", (", ""),
    t({ "", "" }),
    d(2, grid_n, { 1 }),
    t({ "", "))" }),
  }),

  s("mytable", {
    t("#my-table("),
    i(1, "m"),
    t(", "),
    i(2, "n"),
    t(", ("),
    t({ "", "" }),
    d(3, grid_mn, { 1, 2 }),
    t({ "", "))" }),
  }),
})
