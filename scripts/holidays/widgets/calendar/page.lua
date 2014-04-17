local Widget = require "widgets/widget"
local CalendarDay = require "holidays.widgets.calendar.day"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local Text = require "widgets/text"
local HolidaysUtil = require "holidays.util"

local CalendarPage = Class(Widget, function(self)
	Widget._ctor(self, "CalendarPage")

	self.size = { w=1000, h=600 }

	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_PROPORTIONAL)

	self.bg = self:AddChild(Image("images/globalpanels.xml", "panel.tex"))
	self.bg:SetHAnchor(ANCHOR_MIDDLE)
	self.bg:SetVAnchor(ANCHOR_MIDDLE)
	self.bg:SetScaleMode( SCALEMODE_PROPORTIONAL )
	self.bg:SetSize( self.size.w, self.size.h*1.1 )

	self.rightbutton = self:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.rightbutton:SetPosition(550, 0, 0)
    self.rightbutton:SetOnClick( function() self:ShowNextSeason() end)
	
	self.leftbutton = self:AddChild(ImageButton("images/ui.xml", "scroll_arrow.tex", "scroll_arrow_over.tex", "scroll_arrow_disabled.tex"))
    self.leftbutton:SetPosition(-550, 0, 0)
    self.leftbutton:SetScale(-1,1,1)
    self.leftbutton:SetOnClick( function() self:ShowPreviousSeason() end)	
    self.leftbutton:Hide()

	self.days = {}
    self.current_day_offset = GetClock().numcycles+1 - RoundUp( GetSeasonManager():GetDaysIntoSeason()+1 )
    self.current_season = nil
    self.previous_season_length = 0

    self.seasontitle = self:AddChild(Text(BODYTEXTFONT, 40))
    self.seasontitle:SetPosition(0, 200)
    self.seasontitle:SetColour(1,1,1,1)

	self:ShowSeason( GetSeasonManager().current_season )
end)

function CalendarPage:GetSize()
	return self.size.w, self.size.h
end

function CalendarPage:ShowNextSeason()
	if self.current_season == SEASONS.SUMMER then
		self:ShowSeason( "winter" )
	else
		self:ShowSeason( "summer" )
	end
end

function CalendarPage:ShowPreviousSeason()
	if self.current_season == SEASONS.SUMMER then
		self:ShowSeason( "winter", true )
	else
		self:ShowSeason( "summer", true )
	end
end

function CalendarPage:ShowSeason( season, backwards )
	for k,v in pairs(self.days) do
		v:Kill()
	end

	local seasonmanager = GetSeasonManager()
	assert( seasonmanager ~= nil )
	assert( SEASONS[string.upper(season)] ~= nil )

	if seasonmanager.seasonmode == "caves" then
		self.errortext = self:AddChild( Text( BODYTEXTFONT, 60, "Calendar is not functional while in caves" ) )
		self.leftbutton:Hide()
		self.rightbutton:Hide()
		return
	end

	assert( seasonmanager[season.."length"] ~= nil )

	local w,h = self:GetSize()
	w, h = w*.8, h*.65
	--local w, h = TheSim:GetScreenSize()
	local offsetx, offsety = -w/2, h/2-30

	local length = seasonmanager[season.."length"]
	local days_passed = 0
	local current_day = GetClock().numcycles+1
	self.current_day_offset = math.max( 0, self.current_day_offset + (not backwards and self.previous_season_length or -length) )
	if season == seasonmanager.current_season then
		days_passed = RoundUp( seasonmanager:GetDaysIntoSeason()+1 )
		if self.current_day_offset ~= 0 then
			days_passed = 0
		end
	end
	self.current_season = season
	self.previous_season_length = length

	local num_per_row, num_per_col = self:GetNumPerRowAndCol( w, h, length )
	local day_w = w / num_per_row
	local day_h = h / num_per_col
	local full_num_days = length --num_per_row*num_per_col
	--print( "size", w, h, "num_per", num_per_row, num_per_col, "day size", day_w, day_h )

	local holidays = GetWorld().components.holidaymanager:GetHolidaysBySeason( season )

	for i=1,full_num_days do
		local holiday = nil
		for _,v in ipairs(holidays) do
			if v:GetDate() == i then
				holiday = v
			end
		end
		self.days[i] = self:AddChild( CalendarDay( self.current_day_offset+i, holiday, self.current_day_offset+i <= current_day, self.current_day_offset+i == current_day, i > length ) )
		self.days[i]:SetSize( day_w, day_h )
		local x = (i-1) % num_per_row * day_w
		local y = -(math.floor((i-1)/num_per_row)) * day_h
		x = x + offsetx + day_w/2
		y = y + offsety - day_h/2
		self.days[i]:SetPosition( x, y )
		--print( "\tset day["..i.."] x,y="..x..","..y )
	end

	if self.current_day_offset > 0 then
		self.leftbutton:Show()
	else
		self.leftbutton:Hide()
	end

	local current_year = math.floor( self.current_day_offset / seasonmanager:GetYearLength() ) + 1
    self.seasontitle:SetString( "Year "..HolidaysUtil.capitalize( HolidaysUtil.numbertoword( current_year ) )..": "..HolidaysUtil.capitalize( self.current_season ) )
end

function CalendarPage:GetNumPerRowAndCol( x, y, n )
	-- algorithm taken from: http://math.stackexchange.com/questions/466198/algorithm-to-get-the-maximum-size-of-n-squares-that-fit-into-a-rectangle-with-a
	local px = math.ceil(math.sqrt(n*x/y))
	local sx, sy;
	if math.floor(px*y/x)*px<n then	--does not fit, y/(x/px)=px*y/x
		sx = y/math.ceil(px*y/x)
	else
		sx = x/px
	end
	local py = math.ceil(math.sqrt(n*y/x))
	if math.floor(py*x/y)*py<n then	--does not fit
		sy=x/math.ceil(x*py/y);
	else
		sy=y/py
	end
	local sidelength = math.max(sx,sy)

	local numperrow = math.floor( x / sidelength )
	local numpercol = math.floor( y / sidelength )

	return numperrow, numpercol
end

return CalendarPage