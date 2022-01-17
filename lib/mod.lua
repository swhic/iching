local mod = require 'core/mods'

local strategies = require 'iching/strategies'

local strategy = ""

-- The longest card is 5 lines on the Norns display
local param_strats = {"","","","",""}

-- Whether the strategy is unfurled in the params
local iching_state = {
  show=false
}

-- utilities
local function split_string(str)
  local split = {}
  
  for v in string.gmatch(str, "([^%s]+)") do
    table.insert(split, v)
  end
  
  return split
end

local function build_lines(tbl)
  local index = 1
  local line = "" .. table.remove(tbl, 1)
  
  for k,v in ipairs(tbl) do
    if screen.text_extents(line .. " " .. v) <= 128 then
      line = line .. " " .. v
    else
      param_strats[index] = line
      index = index + 1
      line = "" .. v
    end
  end
  
  -- Catch the final line
  if string.len(line) >= 1 then
    param_strats[index] = line
  end
  
  if param_strats[4] == "" then
    table.remove(param_strats, 4)
    table.insert(param_strats, 1, "")
  end

  if param_strats[3] == "" then
    table.remove(param_strats, 3)
    table.insert(param_strats, 1, "")
  end
  
end

local function init_strategy()
  param_strats = {"","","","",""}
end

-- strategy management functions
local function draw_strategy()
  strategy = strategies[ math.random( #strategies ) ]
  return strategy
end

local function update_strats()
  build_lines(split_string(draw_strategy()))
  
  for k,v in ipairs(param_strats) do
    params:set("iching" .. k, v, "")
  end
end

local function toggle_display()
  -- loop through iching lines and flip their display
  -- possibly could also use params.visible to get state?
  if iching_state["show"] then
    -- hide
    for k,v in ipairs(param_strats) do
      params:hide("iching" .. k)
    end
    params:hide("iching_redraw")
    -- set state to false
    iching_state["show"] = false
    _menu.rebuild_params()
  else
    -- show
    for k,v in ipairs(param_strats) do
      params:show("iching" .. k)
    end
    params:show("iching_redraw")
    -- set state to true
    iching_state["show"] = true
    _menu.rebuild_params()
  end
end

-- Add the strategy to the params page
-- It'd be nice to do this post-startup, but that breaks for some reason
mod.hook.register("script_pre_init", "iching setup", function ()
  init_strategy()
  
  params:add_trigger("iching_show", "iching >")
  params:set_action("iching_show", function()
    toggle_display()
  end)
  
  for k,v in ipairs(param_strats) do
    params:add_text("iching" .. k, v, "")
  end
  
  update_strats()
  
  params:add_trigger("iching_redraw", "          draw again")
  params:set_action("iching_redraw", function(x)
    init_strategy()
    update_strats()
    _menu.rebuild_params() 
  end)
  
  if iching_state["show"] then
    for k,v in ipairs(param_strats) do
      params:show("iching" .. k)
    end
    params:show("iching_redraw")
    _menu.rebuild_params()
  else
    for k,v in ipairs(param_strats) do
      params:hide("iching" .. k)
    end
    params:hide("iching_redraw")
    _menu.rebuild_params()
  end
end)
