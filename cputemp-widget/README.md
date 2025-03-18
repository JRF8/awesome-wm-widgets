# AwesomeWM CPU Temperature Widget

## Credits
This AwesomeWM CPU temperature widget was developed with the assistance of
Google's Gemini. Gemini provided helpful code examples, explanations, and
debugging support.

## About

This AwesomeWM widget displays your CPU temperature in your wibar. It provides visual feedback through color-coded text and optional desktop notifications for critical and warning temperatures.

## Features

* Displays CPU temperature in Celsius.
* Color-coded text:
    * White (default): Normal temperature.
    * Orange: Warning temperature.
    * Red: Critical temperature.
* Optional desktop notifications for warning and critical temperatures.
* Configurable update interval, temperature thresholds, and sensor command.

## Prerequisites

* AwesomeWM
* `lm-sensors` (install with `sudo apt install lm-sensors` or your distribution's equivalent)
* `sensors` command properly configured (run `sudo sensors-detect`)
* `naughty` notification library (install with your distributions package manager)

## Installation

1.  **Save the widget:**
    * Create a file named `cpu_temp_widget.lua` in your AwesomeWM configuration directory (e.g., `~/.config/awesome/`).
    * Copy and paste the `cpu_temp_widget.lua` code into the file.
2.  **Require the widget:**
    * In your `rc.lua` file, add the following line:

    ```lua
    local cpu_temp_widget = require("cpu_temp_widget")
    ```

3.  **Add the widget to your wibar:**
    * In your `rc.lua` file, within your `mywibar:setup` function, add the widget:

    ```lua
    mywibar:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left
        layout = wibox.layout.fixed.horizontal,
        -- ... other left widgets ...
      },
      { -- Middle
        layout = wibox.layout.fixed.horizontal,
        -- ... other middle widgets ...
      },
      { -- Right
        layout = wibox.layout.fixed.horizontal,
        cpu_temp_widget:new({
          update_interval = 5, -- seconds
          critical_temp = 85, -- Celsius
          warning_temp = 75, -- Celsius
          temp_command = "sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/\\+//; s/\\.\\..*//'", -- adjust command if needed.
          critical_notification = true, -- enable critical notification
          warning_notification = true, --enable warning notification
        }),
        -- ... other right widgets ...
      },
    }
    ```

4.  **Restart AwesomeWM:**
    * Restart AwesomeWM (`Super + Ctrl + r`) to apply the changes.

## Configuration

You can customize the widget by passing arguments to the `cpu_temp_widget:new()` function:

* `update_interval`: The interval in seconds to update the temperature (default: 5).
* `critical_temp`: The critical temperature threshold in Celsius (default: 80).
* `warning_temp`: The warning temperature threshold in Celsius (default: 70).
* `temp_command`: The command to get the CPU temperature (default: `"sensors | grep 'Package id 0:' | awk '{print $4}' | sed 's/\\+//; s/\\.\\..*//'"`). Adjust this command if needed for your system's `sensors` output.
* `critical_notification`: Enable desktop notifications for critical temperatures (default: `true`).
* `warning_notification`: Enable desktop notifications for warning temperatures (default: `true`).

## Example Configuration

```lua
cpu_temp_widget:new({
  update_interval = 10,
  critical_temp = 90,
  warning_temp = 80,
  temp_command = "sensors | grep 'Core 0:' | awk '{print $3}' | sed 's/\\+//; s/\\.\\..*//'",
  critical_notification = false,
  warning_notification = false,
})