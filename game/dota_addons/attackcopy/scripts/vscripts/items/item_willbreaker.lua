--[[Author: Nightborn
	Date: August 27, 2016
]]


item_willbreaker = class({})


function item_willbreaker:GetIntrinsicModifierName()
    return "modifier_item_willbreaker"
end



LinkLuaModifier("modifier_item_willbreaker", "items/item_willbreaker.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_willbreaker = class({})


if IsServer() then
    function modifier_item_willbreaker:OnCreated()
        local parent = self:GetParent()
        if parent and not parent:IsIllusion() then
            self.modifier = parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_willbreaker_thinker", {})
        end
    end
	
	function modifier_item_willbreaker:OnDestroy()
		self.modifier:Destroy()
    end
end


function modifier_item_willbreaker:IsHidden()
    return true
end

function modifier_item_willbreaker:IsPurgable()
	return false
end

function modifier_item_willbreaker:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_willbreaker:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end


function modifier_item_willbreaker:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_strength")
end


function modifier_item_willbreaker:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
LinkLuaModifier("modifier_item_willbreaker_debuff", "items/item_willbreaker.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_willbreaker_debuff = class({})

function modifier_item_willbreaker_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_item_willbreaker_debuff:IsHidden()
    return false
end

function modifier_item_willbreaker_debuff:IsPurgable()
	return false
end

function modifier_item_willbreaker_debuff:GetModifierPhysicalArmorBonus()
    return -self:GetStackCount()
end

function modifier_item_willbreaker_debuff:OnCreated(keys)
    self.armor_reduce = keys.armor_reduce
end

LinkLuaModifier("modifier_item_willbreaker_thinker", "items/item_willbreaker.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_willbreaker_thinker = class({})


function modifier_item_willbreaker_thinker:IsHidden()
    return true
end

function modifier_item_willbreaker_thinker:IsPurgable()
	return false
end
function modifier_item_willbreaker_thinker:RemoveOnDeath()
    return false
end


if IsServer() then
    function modifier_item_willbreaker_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        }
    end
	
	function modifier_item_willbreaker_thinker:OnCreated()
		self.ability = self:GetAbility()
		self.armor_reduction = self.ability:GetSpecialValueFor("armor_reduction_pct") * 0.01
		self.duration = self.ability:GetSpecialValueFor("duration")
	end
	
	function modifier_item_willbreaker_thinker:GetModifierPreAttack_CriticalStrike()
		if self.ability:IsCooldownReady() then
			return 101
		end
	end

	function modifier_item_willbreaker_thinker:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		
		
		if attacker == self:GetParent() and not target:IsNull() then 
			if self.ability:IsCooldownReady() then
				local modifier = target:AddNewModifier(
					attacker,
					self.ability,
					"modifier_item_willbreaker_debuff", -- modifier name
					{duration = self.duration} -- kv
				)
				modifier:SetStackCount(target:GetPhysicalArmorBaseValue() * self.armor_reduction)
				self.ability:UseResources(false, false, true)
				local particle = ParticleManager:CreateParticle("particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_burst_spark.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
	end
end

