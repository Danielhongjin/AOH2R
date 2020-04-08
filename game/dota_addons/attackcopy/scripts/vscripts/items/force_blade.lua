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


if IsServer() then
    function modifier_item_force_blade:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_force_blade_tinker", {})
        end
    end
end


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
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


LinkLuaModifier("modifier_item_force_blade_tinker", "items/force_blade.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_force_blade_tinker = class({})


function modifier_item_force_blade_tinker:IsHidden()
    return true
end

function modifier_item_force_blade_tinker:IsPurgable()
	return false
end
function modifier_item_force_blade_tinker:RemoveOnDeath()
    return false
end


if IsServer() then
    function modifier_item_force_blade_tinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
	
	function modifier_item_force_blade_tinker:OnCreated()
		local ability = self:GetAbility()
		self.magic_percent = self:GetAbility():GetSpecialValueFor("magic_percent") * 0.01
	end


	function modifier_item_force_blade_tinker:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		
		
		if attacker == self:GetParent() and not target:IsNull() then 
			if not attacker:HasModifier("modifier_item_force_blade") then
				self:Destroy()
				return nil
			end
	
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

