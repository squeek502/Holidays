
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
local print = GLOBAL.print
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local GetWorld = GLOBAL.GetWorld
local SpawnPrefab = GLOBAL.SpawnPrefab
local Vector3 = GLOBAL.Vector3
local GetClock = GLOBAL.GetClock
local GetString = GLOBAL.GetString

--[[
	Add trick-or-treat action
]]--

-- trick or treat (only used when you are able to trick or treat)
-- non-instant
local TRICKORTREAT = Action(0, false)
TRICKORTREAT.str = "Trick-or-treat"
TRICKORTREAT.id = "TRICKORTREAT"
TRICKORTREAT.fn = function(act)
	if act.target.components.trickortreatable then
		act.target.components.trickortreatable:TrickOrTreat( act.doer )
		return true
	end
end

-- give feedback on why you can't trick or treat right now
-- instant
local TRYTRICKORTREAT = Action(0, true)
TRYTRICKORTREAT.str = "Trick-or-treat"
TRYTRICKORTREAT.id = "TRYTRICKORTREAT"
TRYTRICKORTREAT.fn = function(act)
	if act.target.components.trickortreatable then
		local reason = act.target.components.trickortreatable:GetCantTrickOrTreatReason( act.doer )

		if reason then
			act.doer.components.locomotor:Stop()
			act.doer.components.talker:Say( reason )
		end

		return true
	end
end

AddAction(TRICKORTREAT)
AddAction(TRYTRICKORTREAT)

AddStategraphActionHandler("wilson", ActionHandler(TRICKORTREAT, "give"))
AddStategraphActionHandler("wilson", ActionHandler(TRYTRICKORTREAT, "talk"))

--[[
	Make houses trick-or-treatable
]]--

local houses = { 
	pighouse = {
		talksound = "dontstarve/pig/grunt",
		refusesound = "dontstarve/pig/PigKingReject",
		givetreatsound = "dontstarve/pig/PigKingHappy",
	},
	rabbithouse = {
		talksound = "dontstarve/creatures/bunnyman/idle_med",
		refusesound = "dontstarve/creatures/bunnyman/angry_idle",
		givetreatsound = "dontstarve/creatures/bunnyman/happy",
	},
	--[[
	mermhouse = {

	},
	]]--
}

local function MakeHouseTrickOrTreatable( house, settings )
	house:AddComponent( "trickortreatable" )
	house.components.trickortreatable.talksound = settings.talksound
	house.components.trickortreatable.refusesound = settings.refusesound
	house.components.trickortreatable.givetreatsound = settings.givetreatsound

	house.components.trickortreatable.treats = require "holidays.halloween.treats"
	house.components.trickortreatable:SetupMaxTreats( 3 )

	house.components.trickortreatable.cantrickortreatfn = function( trickortreater )
		if house.components.spawner and not house.components.spawner:IsOccupied() then
			return GetString(trickortreater.prefab, "TRICKORTREAT", "NOT_HOME")
		end
	end

	house.components.trickortreatable.ontrickortreatfn = function()
		if house.components.playerprox then
			house:DoTaskInTime(1.5, function()
				-- hacky way to get the light to turn on
				house.components.playerprox.onfar(house)
			end)
		end
	end
	house.components.trickortreatable.onseencostumefn = function()
		if house.components.playerprox then
			-- hacky way to get the light to turn off
			house.components.playerprox.onnear(house)
		end
	end
	house.components.trickortreatable.ongivetreatfn = function()
		if house.components.playerprox then
			house:DoTaskInTime(1, function()
				-- hacky way to get the light to turn off
				house.components.playerprox.onnear(house)
			end)
		end
	end
	house.components.trickortreatable.onrefusefn = function()
		if house.components.playerprox then
			-- hacky way to get the light to turn off
			house.components.playerprox.onnear(house)
		end
	end
	house.components.trickortreatable.onoutoftreatsfn = function()
		-- unlight pumpkin lanterns
		if house.trickortreat_halloween_decorations then
			for _,decoration in ipairs(house.trickortreat_halloween_decorations) do
				if decoration.prefab == "pumpkin_lantern" then
					-- copied from pumpkin_lantern.lua
					decoration.AnimState:PlayAnimation("idle_day")
					decoration.Light:Enable(false)
				end
			end
		end
	end

	house:ListenForEvent( "holidaystart", function( _, data )
		if data.holiday:GetId() ~= "halloween" then return end

		-- only spawn at houses with an alive pig
		if house.components.spawner and house.components.spawner:HasChild() then
			local decoration = SpawnPrefab("pumpkin_lantern")
			decoration.persists = false

			local pt = Vector3(house.Transform:GetWorldPosition()) + GLOBAL.TheCamera:GetDownVec() * 1 - GLOBAL.TheCamera:GetRightVec() * 1
			decoration.Transform:SetPosition( pt:Get() )
			decoration.components.inventoryitem.canbepickedup = false

			-- stop fireflies spawning when this is broken
			-- this is the absolute hackiest way to do this
			decoration.components.lootdropper.SpawnLootPrefab = function() end

			-- another hacky way to make sure it never perishes on its own
			decoration.components.perishable.StartPerishing = function() end
			decoration.components.perishable.LongUpdate = function() end

			house.trickortreat_halloween_decorations = { decoration }

			-- turn off lanterns of houses with no treats
			if not house.components.trickortreatable:HasTreats() then
				house.components.trickortreatable.onoutoftreatsfn()
			end
		end
	end, GetWorld())

	house:ListenForEvent( "holidayend", function( _, data )
		if data.holiday:GetId() ~= "halloween" then return end

		if house.trickortreat_halloween_decorations then
			for _,decoration in ipairs(house.trickortreat_halloween_decorations) do
				if decoration.prefab == "pumpkin_lantern" then
					decoration.components.perishable:Perish()
				end
			end
		end
	end, GetWorld())
end

for prefab,settings in pairs(houses) do
	AddPrefabPostInit( prefab, function( inst ) MakeHouseTrickOrTreatable( inst, settings ) end )
end

--[[
	Add utility functions to spawner component
]]--

local Spawner = require "components/spawner"

Spawner.HasChild = function( self )
	return self.child ~= nil
end

Spawner.WillChildRespawn = function( self )
	return self.nextspawntime ~= nil
end

Spawner.IsChildDead = function( self )
	return not self:HasChild() and not self:WillChildRespawn()
end

--[[
	Make player costumed
]]--

-- need to add the component in here, otherwise OnSave doesn't work right
AddPrefabPostInit("world", function(inst)
	GLOBAL.assert( GLOBAL.GetPlayer() == nil )
	local player_prefab = GLOBAL.SaveGameIndex:GetSlotCharacter()

	-- Unfortunately, we can't add new postinits by now. So we have to do
	-- it the hard way...

	GLOBAL.TheSim:LoadPrefabs( {player_prefab} )
	local oldfn = GLOBAL.Prefabs[player_prefab].fn
	GLOBAL.Prefabs[player_prefab].fn = function()
		local inst = oldfn()

		-- Add components here.
		inst:AddComponent("costumed")
		inst.components.costumed.costumes = require "holidays.halloween.costumes"
		inst.components.costumed:DetermineCostume()

		return inst
	end
end)

--[[
	Halloween related stuff
]]--

AddSimPostInit( function(inst)
	inst:ListenForEvent( "holidaystart", function( _, data )
		if data.holiday:GetId() ~= "halloween" then return end

		if not GetClock():IsNight() and inst.components.talker then
			inst.components.talker:Say( GetString( inst.prefab, "TRICKORTREAT", "HALLOWEEN_STARTED" ) )
		end
	end, GetWorld())

	GetWorld():ListenForEvent( "holidaystart", function( _, data ) 
		if data.holiday:GetId() ~= "halloween" then return end

		-- halloween has a dusk that is twice as long and a night that is twice as short
		local clock = GetClock()
		local newnightsegs = clock:GetNightSegs() / 2
		local newdusksegs = clock:GetDuskSegs() * 2
		local newdaysegs = 16 - newdusksegs - newnightsegs
		clock:SetSegs( newdaysegs, newdusksegs, newnightsegs )
	end )

	inst:ListenForEvent( "costumechange", function( _, data )
		-- announce costume changes on Halloween
		if inst.components.talker and GLOBAL.IsHoliday( "halloween" ) then
			local costumename = tostring( data.costume )

			-- so, so hacky, but as far as I can tell this is the best way to do this
			if inst.prefab == "wx78" then costumename = string.upper(costumename) end

			inst.components.talker:Say( string.format( GetString( inst.prefab, "TRICKORTREAT", "DRESSED_AS_SOMETHING" ), costumename ) )
		end
	end )
end)