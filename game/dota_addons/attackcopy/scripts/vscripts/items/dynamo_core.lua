--[[Author: Nightborn
	Date: August 27, 2016
]]
require("lib/my")
require("lib/popup")


item_dynamo_core = class({})


function item_dynamo_core:GetIntrinsicModifierName()
    return "modifier_item_dynamo_core"
end

LinkLuaModifier("modifier_item_dynamo_core", "items/dynamo_core.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_dynamo_core = class({})

function modifier_item_dynamo_core:IsHidden()
    return true
end

function modifier_item_dynamo_core:IsPurgable()
	return false
end

function modifier_item_dynamo_core:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_dynamo_core:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_dynamo_core:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_dynamo_core:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_dynamo_core:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_dynamo_core:GetModifierManaBonus()
    return -self:GetStackCount()
end

if IsServer() then
	function modifier_item_dynamo_core:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_dynamo_core_attack_speed", {})
		self.mana_steal = self:GetAbility():GetSpecialValueFor("mana_steal") * 0.01
		self.reduced_mana = self:GetAbility():GetSpecialValueFor("reduced_mana") * 0.01
		self.reduced_attack_speed = self:GetAbility():GetSpecialValueFor("reduced_attack_speed") * 0.01
		self.modifier:SetStackCount((self.parent:GetDisplayAttackSpeed() + self.modifier:GetStackCount()) * self.reduced_attack_speed)
		self:SetStackCount((self.parent:GetMaxMana() + self:GetStackCount()) * self.reduced_mana)
		self:StartIntervalThink(0.25)
	end

	function modifier_item_dynamo_core:OnIntervalThink()
		self.modifier:SetStackCount((self.parent:GetDisplayAttackSpeed() + self.modifier:GetStackCount()) * self.reduced_attack_speed)
		self:SetStackCount((self.parent:GetMaxMana() + self:GetStackCount()) * self.reduced_mana)
	end
	
	function modifier_item_dynamo_core:OnDestroy(keys)
		self.parent = self:GetParent()
		self.modifier:Destroy()
	end
	
	function modifier_item_dynamo_core:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and not target:IsNull() then 
			attacker:GiveMana(keys.damage * self.mana_steal)
			local fx = ParticleManager:CreateParticle("particles/custom/dynamo_core.vpcf", PATTACH_POINT_FOLLOW, attacker)
			ParticleManager:SetParticleControlEnt(
				fx,
				0,
				attacker,
				PATTACH_POINT,
				"attach_hitloc",
				attacker:GetAbsOrigin(), -- unknown
				true -- unknown, true
			)
		end
	end
end

LinkLuaModifier("modifier_item_dynamo_core_attack_speed", "items/dynamo_core.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_dynamo_core_attack_speed = class({})

function modifier_item_dynamo_core_attack_speed:IsHidden()
    return true
end

function modifier_item_dynamo_core_attack_speed:IsPurgable()
	return false
end
function modifier_item_dynamo_core_attack_speed:RemoveOnDeath()
    return false
end

function modifier_item_dynamo_core_attack_speed:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_dynamo_core_attack_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_item_dynamo_core_attack_speed:GetModifierAttackSpeedBonus_Constant()
	return -self:GetStackCount()
end
