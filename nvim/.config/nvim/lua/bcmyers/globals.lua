DBG = function(val)
  local time = os.date "%H:%M"
  require("notify")(vim.inspect(val), "debug", { title = "Debug", time })
  return val
end

P = function(val)
  print(vim.inspect(val))
  return val
end

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end
