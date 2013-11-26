-- Holidays in Don't Starve

modimport "use.lua"
use:ExportAs "usage.use"

--[[
	Core
]]--

local require = GLOBAL.require
require "holidays.uiholidays"
require "holidays.seasonmanagerutil"
require "holidays.calendar"
local Holiday = require "holidays.holiday"
local CalendarControls = require "holidays.uicalendar"

--[[
	Holidays
]]--

local halloween = Holiday( "Halloween", "summer", .8335 )
halloween.uisymbol.symbol = "halloween"
halloween:SetTextColor(.43,.16,0,1)

local gobblerday = Holiday( "Gobbler Day", "summer", 0 ) -- last day of summer
gobblerday.uisymbol.symbol = "gobblerday"
gobblerday:SetTextColor(.26,.19,.14,1)

local krampmas = Holiday( "Krampmas", "winter", .2778 )
krampmas.uisymbol.symbol = "christmas"
krampmas:SetTextColor(0,.37,.08,1)

local firstday_summer = Holiday( "First Day Of Summer", "summer", 1 )
firstday_summer:SetTextColor(.43,.42,0,1)

local firstday_winter = Holiday( "First Day Of Winter", "winter", 1 )
firstday_winter:SetTextColor(0,.26,.43,1)

local holidays = { 
	halloween,
	gobblerday,
	krampmas,
	firstday_summer,
	firstday_winter,
}
TUNING.HOLIDAYS = TUNING.HOLIDAYS or {}

for _,holiday in ipairs( holidays ) do
	local holidaydir = "scripts/holidays/"..holiday:GetId().."/"
	tryuse( holidaydir.."main" )
	tryuse( holidaydir.."strings" )
	TUNING.HOLIDAYS[string.upper(holiday:GetId())] = tryuse( holidaydir.."tuning" ) or {}
end

AddSimPostInit( function( char ) 
	local world = GLOBAL.GetWorld()
	if not world.components.holidaymanager then
		world:AddComponent( "holidaymanager" )
		world.components.holidaymanager.holidays = holidays
		world.components.holidaymanager:CheckForHolidays()
	end

	local controls = char.HUD.controls

	controls.calendarcontrols = controls.bottomright_root:AddChild( CalendarControls() )
	controls.calendarcontrols:SetPosition(-60,140,0)
end )


GLOBAL.HolidaysMod_AddHoliday = function( holidaytoadd )
	local world = GLOBAL.GetWorld()
	if world and world.components.holidaymanager then
		table.insert( world.components.holidaymanager.holidays, holidaytoadd )
		return true
	end
	return false
end

GLOBAL.IsHoliday = function( holiday )
	local world = GLOBAL.GetWorld()
	if world and world.components.holidaymanager then
		return world.components.holidaymanager:IsHoliday( holiday )
	end
	return false
end

--[[
	Prefabs and assets
]]--

PrefabFiles = {

}

Assets = {
	Asset( "ANIM", "anim/holidays.zip" ),
	Asset( "IMAGE", "images/hud/calendar.tex" ),
	Asset( "ATLAS", "images/hud/calendar.xml" ),
	Asset( "IMAGE", "images/hud/calendar/crossout.tex" ),
	Asset( "ATLAS", "images/hud/calendar/crossout.xml" ),
	Asset( "IMAGE", "images/hud/calendar/circled.tex" ),
	Asset( "ATLAS", "images/hud/calendar/circled.xml" ),
	Asset( "IMAGE", "images/hud/calendar/day.tex" ),
	Asset( "ATLAS", "images/hud/calendar/day.xml" ),
}