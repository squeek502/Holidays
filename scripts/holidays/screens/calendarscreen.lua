local Screen = require "widgets/screen"
local MAX_HUD_SCALE = 1.25

local Widget = require "widgets/widget"
local CalendarControls = require "holidays.uicalendar"
local CalendarPage = require "holidays.widgets.calendar.page"

local CalendarScreen = Class(Screen, function(self)
	Screen._ctor(self, "CalendarScreen")

	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
	self.bg:SetTint(BGCOLOURS.RED[1], BGCOLOURS.RED[2], BGCOLOURS.RED[3], 1)
	--self.bg:SetTint(1, .9, .75, 1)
	self.bg:SetVRegPoint(ANCHOR_MIDDLE)
	self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetVAnchor(ANCHOR_MIDDLE)
	self.bg:SetHAnchor(ANCHOR_MIDDLE)
	self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.bg.inst.ImageWidget:SetBlendMode( BLENDMODE.Premultiplied )

	local scale = TheFrontEnd:GetHUDScale()

	self.root = self:AddChild(Widget("root"))

	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.root = self.root:AddChild(Widget("scale_root"))
	self.root:SetScale(scale)

	self.calendarpage = self.root:AddChild( CalendarPage() )
	
	self.bottomright_root = self:AddChild(Widget("br_root"))

	self.bottomright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.bottomright_root:SetHAnchor(ANCHOR_RIGHT)
	self.bottomright_root:SetVAnchor(ANCHOR_BOTTOM)
	self.bottomright_root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.bottomright_root = self.bottomright_root:AddChild(Widget("br_scale_root"))
	self.bottomright_root:SetScale(scale)

	if not TheInput:ControllerAttached() then
		self.calendarcontrols = self.bottomright_root:AddChild(CalendarControls())
		self.calendarcontrols:SetPosition(-60,70,0)
	end
end)

function CalendarScreen:OnBecomeInactive()
	CalendarScreen._base.OnBecomeInactive(self)

	SetPause(false, "calendar")
end

function CalendarScreen:OnBecomeActive()
	CalendarScreen._base.OnBecomeActive(self)

	SetPause(true, "calendar")
end

function CalendarScreen:OnUpdate(dt)

end

function CalendarScreen:OnControl(control, down)
	if CalendarScreen._base.OnControl(self, control, down) then return true end

	-- TODO: Add CONTROL_ for calendar
	if not down and (control == nil or control == CONTROL_CANCEL) then
		ToggleCalendar()
		return true
	end

	if not down then return false end
	if not self.shown then return false end
	
	return false
end

function CalendarScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	
	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	return table.concat(t, "  ")
end

return CalendarScreen