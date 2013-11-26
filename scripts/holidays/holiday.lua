require "class"

local Holiday = Class( function( self, name, season, startdate, length )
	self.name = name
	self.id = string.gsub( string.lower( name ), "%s+", "" )
	self.uisymbol = { anim=nil, symbol=nil }
	self.textcolor = { 0,.1,.25,1 }

	self.active = false
	self.daysleft = nil
	self.daysuntil = nil

	self.length = length or 1 		-- in days
	self.season = season 			-- "winter" or "summer"
	self.startdate = startdate 		-- if > 0 and < 1, used as a percentage of the season
end )

function Holiday:Active()
	return self.active
end

function Holiday:GetId()
	return self.id
end

function Holiday:GetName()
	return self.name
end

function Holiday:SetTextColor( r,g,b,a )
	self.textcolor = { r,g,b,a }
end

function Holiday:GetTextColor()
	return unpack( self.textcolor )
end

function Holiday:GetDate()
	local seasonmanager = GetSeasonManager()

	local holidayseasonlength = seasonmanager[self.season.."length"]
	local holidaydate = self.startdate
	local daysuntilholiday = 0

	if self.startdate > 0 and self.startdate < 1 then
		holidaydate = math.ceil( holidayseasonlength * self.startdate )
	elseif self.startdate <= 0 then
		holidaydate = holidayseasonlength + self.startdate
		holidaydate = holidayseasonlength + self.startdate
	end

	holidaydate = math.min( holidayseasonlength, holidaydate )

	return holidaydate
end

function Holiday:DaysUntil()
	local seasonmanager = GetSeasonManager()
	assert( seasonmanager ~= nil )
	assert( SEASONS[string.upper(self.season)] ~= nil )
	assert( seasonmanager[self.season.."length"] ~= nil )

	local holidayseasonlength = seasonmanager[self.season.."length"]
	local daysuntilholiday = 0

	local holidaydate = self:GetDate()

	if seasonmanager:GetSeason() == SEASONS[string.upper(self.season)] then 
		daysuntilholiday = RoundUp( holidaydate - (seasonmanager:GetDaysIntoSeason()+1) )

		if daysuntilholiday < 0 then
			daysuntilholiday = RoundUp( seasonmanager:GetDaysLeftInSeason() + (seasonmanager:GetYearLength() - holidayseasonlength) + holidaydate )
		end
	else
		daysuntilholiday = RoundUp( holidaydate + seasonmanager:GetDaysLeftInSeason() - 1 )
	end

	print( "Days until "..self:GetName()..": "..tostring(daysuntilholiday) )

	self.daysuntil = daysuntilholiday

	return daysuntilholiday
end

function Holiday:DaysLeft()
	return self:Active() and self.daysleft or 0
end

function Holiday:DoDeltaDaysLeft( delta )
	if self:Active() then
		self.daysleft = self.daysleft + delta
	end
	return self:DaysLeft()
end

function Holiday:OnStart()
	self.active = true
	self.daysleft = self.length

	if self.onholidaystartfn then
		self.onholidaystartfn( self )
	end
end

function Holiday:OnEnd()
	self.active = false

	if self.onholidayendfn then
		self.onholidayendfn( self )
	end
end

function Holiday:GetDebugString()
	local str = tostring( self:GetName() ).." ["..tostring(self:GetId()).."]"
	if self:Active() then 
		str = str.." active; days left="..self:DaysLeft()
	else
		str = str.." days until="..tostring( self.daysuntil )
	end
	return str
end

return Holiday