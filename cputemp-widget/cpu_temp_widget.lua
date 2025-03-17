--[[
This AwesomeWM CPU temperature widget was developed with the assistance of
Google's Gemini. Gemini provided helpful code examples, explanations, and
debugging support.
--]]

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local cpu_temp_widget = {}

function cpu_temp_widget:new(args)
  args = args or {}
  local update_interval = args.update_interval or 5
  local critical_temp = args.critical_temp or 80
  local warning_temp = args.warning_temp or 70
  local temp_command = args.temp_command or "sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/\\+//; s/\\.\\..*//'"

  local widget = wibox.widget {
    {
      id = "temp_text",
      text = "CPU: --°C",
      font = beautiful.font,
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
  }
  local update_temp = function(w)
    return function()
      awful.spawn.easy_async_with_shell(temp_command, function(stdout, stderr, exitcode, signal)
        if signal == 0 then
          local temp = tonumber(string.match(stdout, "(%d+)"))
          if temp then
            local temp_text_widget = w:get_children_by_id("temp_text")[1]
            if temp_text_widget then
              local color = "FFFFFF"-- Default color
              if temp >= critical_temp then
                color = "#FF0000"
                if args.critical_notification then
                  naughty.notify({
                    title = "CPU Temperature Critical",
                    text = "CPU temperature is " .. temp .. "°C",
                    timeout = 5,
                    urgency = "critical",
                  })
                end
              elseif temp >= warning_temp then
                color = "#FFA500"
                if args.warning_notification then
                  naughty.notify({
                    title = "CPU Temperature Warning",
                    text = "CPU temperature is " .. temp .. "°C",
                    timeout = 3,
                    urgency = "normal",
                  })
                end
              end
              local markup = "<span color='" .. color .. "'>CPU: " .. temp .. "°C</span>"
              temp_text_widget:set_markup(markup)
            else
              print("Error: temp_text widget not found")
            end
          else
            local temp_text_widget = w:get_children_by_id("temp_text")[1]
            if temp_text_widget then
              local markup = "<span color='" .. beautiful.xcolor9 .. "'>CPU: Error</span>"
              temp_text_widget:set_markup(markup)
            end
          end
        else
          local temp_text_widget = w:get_children_by_id("temp_text")[1]
          if temp_text_widget then
            local markup = "<span color='" .. beautiful.xcolor9 .. "'>CPU: Error</span>"
            temp_text_widget:set_markup(markup)
          end
        end
      end)
    end
  end

  local update_function = update_temp(widget)

  update_function()
  gears.timer {
    timeout = update_interval,
    autostart = true,
    callback = update_function,
  }

  return widget
end

return cpu_temp_widget
