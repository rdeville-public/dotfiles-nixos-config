---@diagnostic disable undefined-global
local wibox = require("wibox")

return function(widget)
  local container = wibox.widget({
    widget,
    widget = wibox.container.background,
  })

  local old_cursor, old_wibox

  container:connect_signal("mouse::enter", function()
    local w = mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = "hand1"
    end
  end)

  container:connect_signal("mouse::leave", function()
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
  end)

  return container
end
