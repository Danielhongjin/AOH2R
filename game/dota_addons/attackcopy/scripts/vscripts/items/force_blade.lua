--[[Author: Nightborn
	Date: August 27, 2016
]]
require("lib/my")
require("lib/popup")


item_force_blade = class({})


function item_force_blade:GetIntrinsicModifierName()
    return "modifier_item_force_blade"
end

LinkLuaModifier("modifier_item_force_blade", "items/force_blade.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_force_blade = class({})

function modifier_item_force_blade:IsHidden()
    return true
end

function modifier_item_force_blade:IsPurgable()
	return false
end

function modifier_item_force_blade:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_force_blade:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end


function modifier_item_force_blade:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_force_blade:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_force_blade:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end


function modifier_item_force_blade:GetModifierPreAttack_BonusDamage()
    return -self:GetStackCount()
end

function modifier_item_force_blade:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end
if IsServer() then
	function modifier_item_force_blade:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_force_blade_thinker", {})
		self.reduced_damage = self:GetAbility():GetSpecialValueFor("reduced_damage") * 0.01
		self:StartIntervalThink(0.2)
	end

	function modifier_item_force_blade:OnIntervalThink()
		self:SetStackCount((self.parent:GetAverageTrueAttackDamage(self.parent) + self:GetStackCount()) * self.reduced_damage)
	end
	
	function modifier_item_force_blade:OnDestroy(keys)
		self.parent = self:GetParent()
		self.modifier:Destroy()
		self.reduced_damage = self:GetAbility():GetSpecialValueFor("reduced_damage") * 0.01
		self:StartIntervalThink(0.2)
	end
end

LinkLuaModifier("modifier_item_force_blade_thinker", "items/force_blade.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_force_blade_thinker = class({})

function modifier_item_force_blade_thinker:IsHidden()
    return true
end

function modifier_item_force_blade_thinker:IsPurgable()
	return false
end
function modifier_item_force_blade_thinker:RemoveOnDeath()
    return false
end

function modifier_item_force_blade_thinker:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
    function modifier_item_force_blade_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
	
	function modifier_item_force_blade_thinker:OnCreated()
		local ability = self:GetAbility()
		self.magic_percent = self:GetAbility():GetSpecialValueFor("magic_percent") * 0.01
	end

	function modifier_item_force_blade_thinker:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self:GetParent() and not target:IsNull() then 
			local finaldamage = ApplyDamage({
				ability = ability,
				attacker = attacker,
				damage = keys.damage * self.magic_percent,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 16,
				victim = target,
			})
			ParticleManager:CreateParticle("particles/custom/force_blade_child.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			create_popup({
				target = target,
				value = finaldamage,
				color = Vector(100, 95, 237),
				type = "spell",
				pos = 6
			})
		end
	end
end

