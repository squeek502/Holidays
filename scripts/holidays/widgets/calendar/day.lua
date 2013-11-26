local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Button = require "widgets/button"
local Text = require "widgets/text"

local CalendarDay = Class(Widget, function(self, daynum, holiday, ispast, iscurrent, isinactive)
	Widget._ctor(self, "CalendarDay")

	self.size = { w=0, h=0 }
	self.holiday = holiday
	self.ispast = ispast and not iscurrent
	self.iscurrent = iscurrent
	self.isinactive = isinactive

	self.bg = self:AddChild(ImageButton("images/hud/calendar/day.xml", "day.tex"))
    self.bg:SetPosition(0,0,0)
	self.bg:SetText( daynum )
	self.bg.text:SetColour(0,0,0,1)
	self.bg:SetFont(BUTTONFONT)
	self.bg:SetTextSize(30)
	self.bg.text:SetHAlign( ANCHOR_LEFT )

	self.bg.text:SetVAlign(ANCHOR_TOP)
	self.bg.text:SetHAlign(ANCHOR_LEFT)
	--self.bg.text:SetScaleMode(SCALEMODE_PROPORTIONAL)

	if self.holiday then
		self.holidaytext = self.bg:AddChild( Text(BUTTONFONT, 30, holiday:GetName()) )
		self.holidaytext:SetColour( holiday:GetTextColor() )
		self.holidaytext:EnableWordWrap( true )
		self.holidaytext:SetVAlign(ANCHOR_BOTTOM)
	end

	if self.iscurrent then
		self.statusicon = self.bg:AddChild( Image("images/hud/calendar/circled.xml", "circled.tex") )
		self.statusicon:SetTint(0,.5,.1,.75)
	elseif self.ispast then
		self.statusicon = self.bg:AddChild( Image("images/hud/calendar/crossout.xml", "crossout.tex") )
		self.statusicon:SetTint(.25,0,0,.75)
	end
	if self.statusicon then self.statusicon:SetClickable( false ) end

	if self.isinactive then
		self.bg.text:Kill()
    	--self.bg.image:SetTint(.1,.1,.1,1)
    elseif self.iscurrent then
    	--self.bg.image:SetTint(.75,1,.75,1)
    elseif self.ispast then
    	--self.bg.image:SetTint(1,.75,.75,1)
    end

	self.bg.OnGainFocus = ImageButton._base.OnGainFocus
	self.bg.OnLoseFocus = ImageButton._base.OnLoseFocus
	self.bg.Enable = ImageButton._base.Enable
	self.bg.Disable = ImageButton._base.Disable

    --self:SetSize( 100, 100 )
end)

function CalendarDay:GetSize()
	return self.size.w, self.size.h
end

function CalendarDay:SetSize( w, h )
	self.size.w, self.size.h = w, h
	self.bg.image:SetSize( self:GetSize() )
	--self.bg.text:SetPosition(-w/3.6,h/4,0)

	if self.statusicon then
		if self.ispast then
			self.statusicon:SetSize( w*.9, h*.9 )
		elseif self.iscurrent then
			self.statusicon:SetSize( w*1, w*1 )
		end
	end

	if self.holidaytext then
		self.holidaytext:SetRegionSize( w*.9, h*.78 )
	end

	self.bg.text:SetRegionSize( w*.7, h*.7 )
	--self.bg.text:SetPosition(w*.15,-h*.15,0)
end

return CalendarDay