local Costumed = Class(function(self, inst)
	self.inst = inst
	self.costumes = {}

	self.inst:ListenForEvent("equip", function()
		self:DetermineCostume()
	end)
	self.inst:ListenForEvent("unequip", function()
		self:DetermineCostume()
	end)
end)

function Costumed:IsCostumed()
	return self.costume ~= nil
end

function Costumed:GetCostumeName()
	return tostring( self.costume )
end

function Costumed:GetCostumeID()
	return self:IsCostumed() and self.costume.id or "none"
end

function Costumed:SetCostume( costume, wornvalue )
	local oldcostume = self.costume
	local oldwornvalue = self.wornvalue

	self.costume = costume
	self.wornvalue = wornvalue or 0

	if oldcostume ~= self.costume then
		--print( tostring(self.inst).." changed costume from "..tostring(oldcostume).." to "..tostring(self.costume) )
		self.inst:PushEvent("costumechange", { oldcostume=oldcostume, oldwornvalue=oldwornvalue, costume=self.costume, wornvalue=self.wornvalue })
	end
end

function Costumed:ClearCostume()
	self:SetCostume( nil )
end

function Costumed:DetermineCostume()
	local equippeditems = {}
	if self.inst.components.inventory then
	    for _,equippeditem in pairs(self.inst.components.inventory.equipslots) do
	        table.insert(equippeditems, equippeditem)
	    end
	end

    local bestcostume = nil
    local bestwornvalue = 0

    if #equippeditems > 0 then

		for _,costume in ipairs(self.costumes) do
			local wornvalue = costume:GetCostumeWornValue( equippeditems )
			if wornvalue > bestwornvalue then
				bestcostume = costume
				bestwornvalue = wornvalue
			end
		end

	end

	self:SetCostume( bestcostume, bestwornvalue )

	return self.costume
end

function Costumed:GetDebugString()
	local s = ""
	if self:IsCostumed() then
		s = "wearing "..tostring(self:GetCostumeName()).." costume ("..self.wornvalue..")"
	else
		s = "not costumed"
	end
	return s
end

return Costumed