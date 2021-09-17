--[[Author: Nightborn
	Date: August 27, 2016
]]
require("lib/my")
require("lib/popup")


item_glare_edge = class({})


function item_glare_edge:GetIntrinsicModifierName()
    return "modifier_item_glare_edge"
end

LinkLuaModifier("modifier_item_glare_edge", "items/glare_edge.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_glare_edge = class({})

function modifier_item_glare_edge:IsHidden()
    return true
end

function modifier_item_glare_edge:IsPurgable()
	return false
end

function modifier_item_glare_edge:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_glare_edge:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_glare_edge:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_glare_edge:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_glare_edge:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all")
end

function modifier_item_glare_edge:GetModifierDamageOutgoing_Percentage()
    return -self:GetAbility():GetSpecialValueFor("reduced_damage")
end

function modifier_item_glare_edge:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end
if IsServer() then
	function modifier_item_glare_edge:OnCreated(keys)
		local parent = self:GetParent()
		self.modifier = parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_glare_edge_thinker", {})
	end
	
	function modifier_item_glare_edge:OnDestroy(keys)
		self.modifier:Destroy()
	end
end


LinkLuaModifier("modifier_item_glare_edge_thinker", "items/glare_edge.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_glare_edge_thinker = class({})

function modifier_item_glare_edge_thinker:IsHidden()
    return true
end

function modifier_item_glare_edge_thinker:IsPurgable()
	return false
end
function modifier_item_glare_edge_thinker:RemoveOnDeath()
    return false
end

function modifier_item_glare_edge_thinker:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
    function modifier_item_glare_edge_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
	
	function modifier_item_glare_edge_thinker:OnCreated()
		local ability = self:GetAbility()
		self.magic_percent = self:GetAbility():GetSpecialValueFor("magic_percent") * 0.01
	end

	function modifier_item_glare_edge_thinker:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self:GetParent() and not target:IsNull() then 
			local finaldamage = ApplyDamage({
				ability = ability,
				attacker = attacker,
				damage = keys.damage * self.magic_percent,
				damage_type = DAMAGE_TYPE_MAGICAL,
				victim = target,
			})
			local fx = ParticleManager:CreateParticle("particles/custom/glare_edge.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(
				fx,
				0,
				target,
				PATTACH_POINT,
				"attach_hitloc",
				target:GetAbsOrigin(), -- unknown
				true -- unknown, true
			)
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

