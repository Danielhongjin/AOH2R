LinkLuaModifier("modifier_bonus_primary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)

item_custom_apex = class({})

function item_custom_apex:GetIntrinsicModifierName()
    return "modifier_item_custom_apex"
end

LinkLuaModifier("modifier_item_custom_apex", "items/item_custom_apex.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_apex = class({})
function modifier_item_custom_apex:IsHidden()
    return true
end

function modifier_item_custom_apex:IsPurgable()
	return false
end

function modifier_item_custom_apex:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_item_custom_apex:OnCreated()
		local ability = self:GetAbility()
		self.parent = self:GetParent()
		self.parent:AddNewModifier(self.parent, self, "modifier_bonus_primary_controller", {})
		self.modifier = self.parent:AddNewModifier(self.parent, self, "modifier_bonus_primary_token", {
			bonus = ability:GetSpecialValueFor("primary_stat_percent")})
	end
	
	function modifier_item_custom_apex:OnDestroy()
		self.modifier:Destroy()
	end
end