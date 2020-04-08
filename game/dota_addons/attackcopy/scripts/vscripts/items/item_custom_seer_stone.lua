
item_custom_seer_stone = class({})

function item_custom_seer_stone:GetIntrinsicModifierName()
    return "modifier_item_custom_seer_stone"
end

function item_custom_seer_stone:OnOwnerSpawned()
    return "modifier_item_custom_seer_stone"
end

LinkLuaModifier("modifier_item_custom_seer_stone", "items/item_custom_seer_stone.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_seer_stone = class({})

function modifier_item_custom_seer_stone:IsHidden()
    return true
end

function modifier_item_custom_seer_stone:IsPurgable()
	return false
end

function modifier_item_custom_seer_stone:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_item_custom_seer_stone:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.parent:RemoveModifierByName("modifier_item_custom_seer_stone_buff")
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_custom_seer_stone_buff", {})
	end
	
	function modifier_item_custom_seer_stone:OnDestroy()
		self.parent:RemoveModifierByName("modifier_item_custom_seer_stone_buff")
	end
end

LinkLuaModifier("modifier_item_custom_seer_stone_buff", "items/item_custom_seer_stone.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_seer_stone_buff = class({})

function modifier_item_custom_seer_stone_buff:IsHidden()
    return true
end

function modifier_item_custom_seer_stone_buff:IsPurgable()
	return false
end

function modifier_item_custom_seer_stone_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_custom_seer_stone_buff:RemoveOnDeath()
	return false
end
function modifier_item_custom_seer_stone_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
    }
end


function modifier_item_custom_seer_stone_buff:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_custom_seer_stone_buff:GetBonusDayVision()
    return self:GetAbility():GetSpecialValueFor("vision_bonus")
end

function modifier_item_custom_seer_stone_buff:GetBonusNightVision()
    return self:GetAbility():GetSpecialValueFor("vision_bonus")
end

function modifier_item_custom_seer_stone_buff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_custom_seer_stone_buff:GetModifierCastRangeBonusStacking()
    return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

