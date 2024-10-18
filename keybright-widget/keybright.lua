local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")
local gfs = require("gears.filesystem")
local naughty = require("naughty")
local beautiful = require("beautiful")

local ICON_DIR = gfs.get_configuration_dir() .. "awesome-wm-widgets/keybright-widget/"
local get_brightness_cmd
local inc_brightness_cmd
local dec_brightness_cmd

local keybright_widget = {}

local function show_warning(message)
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Keyboard Brightness Widget",
		text = message,
	})
end

local function worker(user_args)
	local args = user_args or {}

	local type = args.type or "arc" -- arc or icon_and_text
	local path_to_icon = args.path_to_icon or ICON_DIR .. "keybright.svg"
	local font = args.font or beautiful.font
	local timeout = args.timeout or 100

	local tooltip = args.tooltip or false
	local percentage = args.percentage or false
	local rmb_set_max = args.rmb_set_max or false
	local size = args.size or 18
	local max_val = args.max_val or 100

	inc_brightness_cmd = "keylight up"
	dec_brightness_cmd = "keylight down"
	--get_brightness_cmd = "cat /sys/class/leds/smc::kbd_backlight/brightness"
	get_brightness_cmd = "keylight get"

	if type == "icon_and_text" then
		keybright_widget.widget = wibox.widget({
			{
				{
					image = path_to_icon,
					resize = false,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				layout = wibox.container.place,
			},
			{
				id = "txt",
				font = font,
				widget = wibox.widget.textbox,
			},
			spacing = 4,
			layout = wibox.layout.fixed.horizontal,
			set_value = function(self, level)
				local display_level = level
				if percentage then
					display_level = display_level .. "%"
				end
				self:get_children_by_id("txt")[1]:set_text(display_level)
			end,
		})
	elseif type == "arc" then
		keybright_widget.widget = wibox.widget({
			{
				{
					image = path_to_icon,
					resize = true,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				layout = wibox.container.place,
			},
			max_value = max_val,
			thickness = 2,
			start_angle = 4.71238898, -- 2pi*3/4
			forced_height = size,
			forced_width = size,
			paddings = 2,
			widget = wibox.container.arcchart,
			set_value = function(self, level)
				self:set_value(level)
			end,
		})
	else
		show_warning(type .. " type is not supported by the widget")
		return
	end

	local update_widget = function(widget, stdout, _, _, _)
		local brightness_level = tonumber(string.format("%.0f", stdout))
		current_level = brightness_level
		widget:set_value(brightness_level)
	end

	local old_level = 0
	function keybright_widget:toggle()
		if rmb_set_max then
			keybright_widget:set(100)
		else
			if old_level < 0.1 then
				-- avoid toggling between '0' and 'almost 0'
				old_level = 1
			end
			if current_level < 0.1 then
				-- restore previous level
				current_level = old_level
			else
				-- save current brightness for later
				old_level = current_level
				current_level = 0
			end
			keybright_widget:set(current_level)
		end
	end
	function keybright_widget:inc()
		spawn.easy_async(inc_brightness_cmd, function()
			spawn.easy_async_with_shell(get_brightness_cmd, function(out)
				update_widget(keybright_widget.widget, out)
			end)
		end)
	end
	function keybright_widget:dec()
		spawn.easy_async(dec_brightness_cmd, function()
			spawn.easy_async_with_shell(get_brightness_cmd, function(out)
				update_widget(keybright_widget.widget, out)
			end)
		end)
	end

	keybright_widget.widget:buttons(awful.util.table.join(
		awful.button({}, 3, function()
			keybright_widget:toggle()
		end),
		awful.button({}, 4, function()
			keybright_widget:inc()
		end),
		awful.button({}, 5, function()
			keybright_widget:dec()
		end)
	))

	watch(get_brightness_cmd, timeout, update_widget, keybright_widget.widget)

	if tooltip then
		awful.tooltip({
			objects = { keybright_widget.widget },
			timer_function = function()
				return current_level .. " %"
			end,
		})
	end

	return keybright_widget.widget
end

return setmetatable(keybright_widget, {
	__call = function(_, ...)
		return worker(...)
	end,
})
