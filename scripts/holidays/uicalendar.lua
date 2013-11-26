local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"

local CalendarControls = Class(Widget, function(self)
	Widget._ctor(self, "Calendar Controls")
    local MAPSCALE = .5
	self.calendarBtn = self:AddChild(ImageButton("images/hud/calendar.xml", "calendar.tex"))
    self.calendarBtn:SetScale(MAPSCALE,MAPSCALE,MAPSCALE)
	self.calendarBtn:SetOnClick( function() ToggleCalendar() end )
	self.calendarBtn:SetTooltip("Open Calendar")
end)

return CalendarControls