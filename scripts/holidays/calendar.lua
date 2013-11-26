local CalendarScreen = require "holidays.screens.calendarscreen"

local t = {}
local calendar_shown = false

function ToggleCalendar()
	if not calendar_shown then
		TheFrontEnd:PushScreen( CalendarScreen() )
	else
		TheFrontEnd:PopScreen()
	end
	calendar_shown = not calendar_shown
end
t.ToggleCalendar = ToggleCalendar

return t