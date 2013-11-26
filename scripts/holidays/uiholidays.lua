local UIClock = require "widgets/uiclock"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local UIClock_ctor_base = UIClock._ctor
UIClock._ctor = function( self, ... )
	UIClock_ctor_base( self, ... )

	self.holidayanim = self:AddChild(UIAnim())
	self.holidayanim:MoveToBack()
	self.holidayanim:SetRotation( -50 )
	self.holidayanim:SetPosition(-15,30,0)
	--self.moonanim:SetScale(.4,.4,.4)
	self.holidayanim:GetAnimState():SetBank("moon_phases_clock")
	self.holidayanim:GetAnimState():SetBuild("moon_phases_clock")
	self.holidayanim:GetAnimState():PlayAnimation("hidden")

	self.holidaytext = self:AddChild(Text(NUMBERFONT, 30/self.base_scale))
	self.holidaytext:SetPosition(-81,-32,0)
	self.holidaytext:Hide()
	self.holidaytext:MoveToFront()

	self.holidayanim.OnGainFocus = function()
		self.holidaytext:Show()
	end
	self.holidayanim.OnLoseFocus = function()
		self.holidaytext:Hide()
	end

	self.inst:ListenForEvent( "holidaystart", function(inst, data) 
		self:ShowHoliday( data.holiday )
	end, GetWorld())

	self.inst:ListenForEvent( "holidayend", function(inst, data) 
		self:HideHoliday( data.holiday )
	end, GetWorld())
end

UIClock.ShowHoliday = function(self, holiday)
	local anim = holiday.uisymbol.anim or "holidays"
	local symbol = holiday.uisymbol.symbol or "generic"
	self.holidayanim:GetAnimState():OverrideSymbol("swap_moon", anim, symbol)
	self.holidayanim:GetAnimState():PlayAnimation("trans_out") 
	self.holidayanim:GetAnimState():PushAnimation("idle", true) 

	self.holidaytext:SetString( holiday:GetName() )
end

UIClock.HideHoliday = function(self, holiday)
	self.holidayanim:GetAnimState():PlayAnimation("trans_in") 
	self.holidayanim:GetAnimState():PushAnimation("hidden", true) 

	self.holidaytext:SetString( "" )
end

return UIClock