
LinkLuaModifier("modifier_item_sanguine", "items/item_sanguine.lua", LUA_MODIFIER_MOTION_NONE)



item_sanguine = class({})

function item_sanguine:GetIntrinsicModifierName()
    return "modifier_item_sanguine"
end

item_sanguine_2 = class(item_sanguine)
item_sanguine_3 = class(item_sanguine)
item_sanguine_4 = class(item_sanguine)



modifier_item_sanguine = class({})


function modifier_item_sanguine:IsHidden()
    return true
end
function modifier_item_sanguine:IsPurgable()
	return false
end
function modifier_item_sanguine:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_sanguine:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_sanguine:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_sanguine:GetModifierMagicalResistanceBonus()
        return self:GetAbility():GetSpecialValueFor("bonus_magical_resistance")
end

function modifier_item_sanguine:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_item_sanguine:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_item_sanguine:OnCreated()
	self.health_damage_bonus = self:GetAbility():GetSpecialValueFor("health_damage_bonus") * 0.01
	self.damage_ratio = self:GetAbility():GetSpecialValueFor("damage_ratio") * 0.01
	self.parent = self:GetParent()
	if not self.parent:IsIllusion() then
		self:StartIntervalThink(0.33)
	end
end
	
if IsServer() then

	function modifier_item_sanguine:OnIntervalThink()
		self:SetStackCount(self.parent:GetMaxHealth() * self.health_damage_bonus)
	end
	
    function modifier_item_sanguine:OnAttackLanded(keys)
        local attacker = keys.attacker
        local target = keys.target
		if not self.parent:IsIllusion() then
			if attacker == self.parent and attacker ~= target then
				ApplyDamage({
					ability = ability,
					attacker = attacker,
					damage = self.parent:GetMaxHealth() * self.health_damage_bonus * self.damage_ratio,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
					victim = attacker,
				})
				local particle = ParticleManager:CreateParticle("particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_soft.vpcf", PATTACH_POINT_FOLLOW, attacker)
				ParticleManager:SetParticleControlEnt(particle, 0, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true) 
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
    end
end
