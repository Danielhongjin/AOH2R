require("lib/my")


custom_weaver_behavior = class({})


function custom_weaver_behavior:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_custom_weaver_behavior"
	end
end




LinkLuaModifier("modifier_custom_weaver_behavior", "bosses/custom_weaver_behavior.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_weaver_behavior = class({})


function modifier_custom_weaver_behavior:IsHidden()
    return true
end
function modifier_custom_weaver_behavior:IsPurgable()
	return false
end


if IsServer() then
	function modifier_custom_weaver_behavior:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.itemAbility = self.parent:AddItemByName("item_flicker_boss")
		self.interval = self.ability:GetSpecialValueFor("interval")
		Timers:CreateTimer(
			0.01 * RandomInt(0, 100), 
			function()
				self:StartIntervalThink(self.interval)
			end
		)
		
	end
end
function modifier_custom_weaver_behavior:OnIntervalThink()
	self.itemAbility:CastAbility()
end




