LinkLuaModifier("modifier_bonus_secondary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)


item_shadow_banner = class({})
function item_shadow_banner:GetIntrinsicModifierName()
    return "modifier_item_shadow_banner"
end

item_infinite_rapier = class(item_shadow_banner)

LinkLuaModifier("modifier_item_shadow_banner", "items/item_shadow_banner.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_shadow_banner = class({})

function modifier_item_shadow_banner:IsHidden()
    return true
end

function modifier_item_shadow_banner:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end

function modifier_item_shadow_banner:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_shadow_banner:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_shadow_banner:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_shadow_banner:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_shadow_banner:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

if IsServer() then

	function modifier_item_shadow_banner:OnCreated()
		local illusions = CreateIllusions(self:GetParent(), self:GetParent(), {duration = -1, outgoing_damage =  self:GetAbility():GetSpecialValueFor("images_do_damage_percent_melee"), incoming_damage =  self:GetAbility():GetSpecialValueFor("bonus_intellect")},  self:GetAbility():GetSpecialValueFor("images_take_damage_percent"), 50, true, true )
		self.illusion = illusions[1]
	end

end