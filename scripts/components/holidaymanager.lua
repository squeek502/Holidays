
local HolidayManager = Class(function(self, inst)
	self.inst = inst

	self.holidays = {}

	self.inst:ListenForEvent( "daycomplete", function() self:DayPassed() end )
end)

function HolidayManager:DayPassed()
	for _,holiday in ipairs(self.holidays) do
		if holiday:Active() then
			holiday:DoDeltaDaysLeft( -1 )
		end
	end
	self:CheckForHolidays()
end

function HolidayManager:CheckForHolidays()
	for _,holiday in ipairs(self.holidays) do
		if holiday:Active() then
			if holiday:DaysLeft() <= 0 then
				self:EndHoliday( holiday )
			end
		else
			if holiday:DaysUntil() <= 0 then
				self:StartHoliday( holiday )
			end
		end
	end
end

function HolidayManager:GetHoliday( holidaytofind )
	local holidayid = type(holidaytofind) == "string" and holidaytofind or holidaytofind:GetId()
	for _,holiday in ipairs(self.holidays) do
		if string.lower(holiday:GetId()) == string.lower(holidayid) then
			return holiday
		end
	end
	return nil
end

function HolidayManager:GetHolidaysBySeason( season )
	local holidays = {}
	for _,holiday in ipairs(self.holidays) do
		if holiday.season == season then
			table.insert( holidays, holiday )
		end
	end
	return holidays
end

function HolidayManager:IsHoliday( holiday )
	holiday = self:GetHoliday( holiday )
	return holiday and holiday:Active()
end

function HolidayManager:StartHoliday( holiday )
	if not holiday:Active() then
		holiday:OnStart()

		print("StartHoliday: "..holiday:GetName())
		self.inst:PushEvent("holidaystart", { holiday=holiday })
	else
		print("StartHoliday: It is already "..holiday:GetName())
	end
end

function HolidayManager:EndHoliday( holiday )
	if holiday:Active() then
		holiday:OnEnd()

		print("EndHoliday: "..holiday:GetName())
		self.inst:PushEvent("holidayend", { holiday=holiday })
	else
		print("EndHoliday: It is not "..holiday:GetName())
	end
end

function HolidayManager:GetDebugString()
	local str = ""..#self.holidays.." holidays"

	for _,holiday in ipairs(self.holidays) do
		str = str.."\n\t"..holiday:GetDebugString()
	end
	
	return str
end

return HolidayManager