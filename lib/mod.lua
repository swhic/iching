local mod = require 'core/mods'

local strategies = require 'oblique/strategies'

local strategy = ""

local function draw_strategy()
  strategy = strategies[ math.random( #strategies ) ]
  return strategy
end

local function split_string(str)
  local split = {}
  
  for v in string.gmatch(str, "([^%s]+)") do
    table.insert(split, v)
  end
  
  return split
end

local function build_lines(tbl)
  local strats = {}
  local index = 1
  local line = "" .. table.remove(tbl, 1)
  
  for k,v in ipairs(tbl) do
    if screen.text_extents(line .. " " .. v) <= 128 then
      line = line .. " " .. v
    else
      table.insert(strats, index, line)
      index = index + 1
      line = "" .. v
    end
  end
  
  if string.len(line) >= 1 then
    table.insert(strats, index, line)
  end
  
  return strats
end


-- Add the strategy to the params page ////////
-- It'd be nice to do this post-startup, but that breaks for some reason
mod.hook.register("script_pre_init", "oblique setup", function ()
  local strategy = draw_strategy()
  local split = split_string(strategy)
  local strats = build_lines(split)
  
  params:add_separator("THE CARD SAYS")
  
  for k,v in ipairs(strats) do
    params:add_text("strat" .. k, v, "")
  end
  
  params:add_separator()
end)


--
-- [optional] returning a value from the module allows the mod to provide
-- library functionality to scripts via the normal lua `require` function.
--
-- NOTE: it is important for scripts to use `require` to load mod functionality
-- instead of the norns specific `include` function. using `require` ensures
-- that only one copy of the mod is loaded. if a script were to use `include`
-- new copies of the menu, hook functions, and state would be loaded replacing
-- the previous registered functions/menu each time a script was run.
--
-- here we provide a single function which allows a script to get the mod's
-- state table. using this in a script would look like:
--
-- local mod = require 'name_of_mod/lib/mod'
-- local the_state = mod.get_state()
--
local api = {}

api.get_strategy = function()
  return strategy
end

return api