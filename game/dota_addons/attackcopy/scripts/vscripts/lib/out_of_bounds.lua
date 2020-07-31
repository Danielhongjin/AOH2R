function OnStartTouch(trigger)
	print("hey wutup comeboy")
	trigger.activator:AddNewModifier(trigger.activator, nil, "modifier_out_of_bounds", {duration = -1})
	
end

function OnEndTouch(trigger)
	trigger.activator:RemoveModifierByName("modifier_out_of_bounds")
	print(trigger.activator)
	print(trigger.caller)
	
end


LinkLuaModifier("modifier_out_of_bounds", "lib/out_of_bounds.lua", LUA_MODIFIER_MOTION_NONE)
modifier_out_of_bounds = class({})

function modifier_out_of_bounds:IsPurgable()
    return false
end

function modifier_out_of_bounds:IsHidden()
    return false
end

function modifier_out_of_bounds:RemoveOnDeath()
    return true
end

if IsServer() then
function modifier_out_of_bounds:OnCreated()
	self.parent = self:GetParent()
	print(self.parent:GetUnitName())
	self.interval = 0.25
	self.health_reduction = 0.05 * self.interval
	
    self:StartIntervalThink(self.interval)
end

function modifier_out_of_bounds:OnIntervalThink()
    self.parent:SetHealth(self.parent:GetHealth() - (self.parent:GetMaxHealth() * self.health_reduction))
end
end