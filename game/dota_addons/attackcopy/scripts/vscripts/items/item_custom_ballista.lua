require("lib/popup")
item_custom_ballista = class({})

function item_custom_ballista:GetIntrinsicModifierName()
    return "modifier_item_custom_ballista"
end

LinkLuaModifier("modifier_item_custom_ballista", "items/item_custom_ballista.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_ballista = class({})
function modifier_item_custom_ballista:IsHidden()
    return true
end

function modifier_item_custom_ballista:IsPurgable()
	return false
end

function modifier_item_custom_ballista:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_item_custom_ballista:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.parent:RemoveModifierByName("modifier_item_custom_ballista_buff")
		self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_custom_ballista_buff", {})
	end
	
	function modifier_item_custom_ballista:OnDestroy()
		self.parent:RemoveModifierByName("modifier_item_custom_ballista_buff")
	end
end
LinkLuaModifier("modifier_item_custom_ballista_buff", "items/item_custom_ballista.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_ballista_buff = class({})

function modifier_item_custom_ballista_buff:IsHidden()
    return true
end

function modifier_item_custom_ballista_buff:IsPurgable()
	return false
end

function modifier_item_custom_ballista_buff:RemoveOnDeath()
	return false
end

function modifier_item_custom_ballista_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_ballista_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_item_custom_ballista_buff:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("attack_range_bonus")
end

function modifier_item_custom_ballista_buff:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_custom_ballista_buff:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_custom_ballista_buff:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_custom_ballista_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

if IsServer() then
	function modifier_item_custom_ballista_buff:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	end
	function modifier_item_custom_ballista_buff:OnAttackLanded(keys)
        local attacker = keys.attacker
		local target = keys.target
        if attacker == self.parent and not attacker:IsNull() then
			ApplyDamage({
				ability = self.ability,
				attacker = attacker,
				damage = self.bonus_damage,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = 16,
				victim = target,
			})
			create_popup({
				target = target,
				value = self.bonus_damage,
				color = Vector(183, 47, 234),
				type = "spell",
				pos = 6
			})
		end
	end
end