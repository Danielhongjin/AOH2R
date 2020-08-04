LinkLuaModifier("modifier_legion_commander_warpath", "abilities/heroes/legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legion_commander_damage_hidden", "abilities/heroes/legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legion_commander_damage", "abilities/heroes/legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_legion_commander_damage_permanent", "abilities/heroes/legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/timers")
legion_commander_warpath = class({})

function legion_commander_warpath:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	if caster:HasScepter() and not caster:HasModifier("modifier_legion_commander_damage_permanent") and caster:HasModifier("modifier_legion_commander_damage_hidden") then
		local counter = caster:FindModifierByName("modifier_legion_commander_damage_hidden")
		modifier = caster:AddNewModifier(caster, self, "modifier_legion_commander_damage_permanent", {duration = -1})
		modifier:SetStackCount(counter:GetStackCount() * self:GetSpecialValueFor("scepter_ratio") * 0.01)
	elseif not caster:HasScepter() and caster:HasModifier("modifier_legion_commander_damage_permanent") then
		caster:RemoveModifierByName("modifier_legion_commander_damage_permanent")
	end
end
function legion_commander_warpath:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	if caster:HasScepter() then
		duration = self:GetSpecialValueFor("duration_scepter")
	end
	caster:Purge(false, true, false, true, false)
	caster:AddNewModifier(caster, self, "modifier_legion_commander_warpath", {duration = duration})
	local increment = self:GetSpecialValueFor("reward_damage")
	if caster:HasAbility("special_bonus_unique_legion_commander") then
		local talent = caster:FindAbilityByName("special_bonus_unique_legion_commander")
		if talent:GetLevel() > 0 then
			increment = increment + talent:GetSpecialValueFor("value")
		end
	end
	if not caster:HasModifier("modifier_legion_commander_damage_hidden") then
		local hidden = caster:AddNewModifier(caster, self, "modifier_legion_commander_damage_hidden", {duration = -1})
	end
	local counter = caster:FindModifierByName("modifier_legion_commander_damage_hidden")
	counter:SetStackCount(counter:GetStackCount() + increment)
	local modifier = caster:AddNewModifier(caster, self, "modifier_legion_commander_damage", {duration = duration})
	modifier:SetStackCount(counter:GetStackCount())
	if caster:HasScepter() then
		if caster:HasModifier("modifier_legion_commander_damage_permanent") then
			caster:FindModifierByName("modifier_legion_commander_damage_permanent"):SetStackCount(counter:GetStackCount() * self:GetSpecialValueFor("scepter_ratio") * 0.01)
		else
			local modifier = caster:AddNewModifier(caster, self, "modifier_legion_commander_damage_permanent", {duration = -1})
			modifier:SetStackCount(counter:GetStackCount() * self:GetSpecialValueFor("scepter_ratio") * 0.01)
		end
	end
	
end
modifier_legion_commander_warpath = class({})

function modifier_legion_commander_warpath:IsPurgable()
	return true
end

function modifier_legion_commander_warpath:IsHidden()
	return true
end

function modifier_legion_commander_warpath:GetStatusEffectName()
	return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf"
end

function modifier_legion_commander_warpath:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACKED,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
    }
end


function modifier_legion_commander_warpath:GetModifierMoveSpeed_AbsoluteMin()
    return self:GetAbility():GetSpecialValueFor("minimum_movespeed")
end

function modifier_legion_commander_warpath:GetModifierTurnRate_Percentage()
    return self:GetAbility():GetSpecialValueFor("turn_rate")
end

function modifier_legion_commander_warpath:GetModifierPercentageCasttime()
    return self:GetAbility():GetSpecialValueFor("cast_time_percentage")
end

function modifier_legion_commander_warpath:GetModifierModelScale()
    return 15
end

if IsServer() then
	function modifier_legion_commander_warpath:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.delay = ability:GetSpecialValueFor("delay")
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_ring.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(fx)
		self.parent:EmitSound("Hero_LegionCommander.Duel.Cast")
		self.parent:EmitSound("Hero_LegionCommander.Duel.FP")
		self:StartIntervalThink(6)
	end
	
	function modifier_legion_commander_warpath:OnAttacked(keys)
		local attacker = keys.attacker
		local victim = keys.target
		if self.parent == attacker and not keys.no_attack_cooldown then
			local fx = ParticleManager:CreateParticle("particles/custom/custom_odds_arrow_start_pos.vpcf", PATTACH_WORLDORIGIN, self.parent)
			ParticleManager:SetParticleControl(fx, 0, victim:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 9, Vector(self.delay, 0, 0))
			ParticleManager:ReleaseParticleIndex(fx)
			local fx = ParticleManager:CreateParticle("particles/custom/custom_odds_arrow_start_pos.vpcf", PATTACH_WORLDORIGIN, self.parent)
			ParticleManager:SetParticleControl(fx, 0, victim:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, self.parent:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 9, Vector(self.delay, 0, 0))
			ParticleManager:ReleaseParticleIndex(fx)
			Timers:CreateTimer(
				self.delay, 
				function()
					EmitSoundOnLocationWithCaster(victim:GetAbsOrigin(), "Hero_LegionCommander.Overwhelming.Creep", self.parent)
					self.parent:PerformAttack(victim, false, true, true, true, false, false, true)
				end
			)
		end
	end
	
	function modifier_legion_commander_warpath:OnIntervalThink()
		self.parent:EmitSound("Hero_LegionCommander.Duel.FP")
	end	
	
	function modifier_legion_commander_warpath:OnDestroy()
		self.parent:StopSound("Hero_LegionCommander.Duel.FP")
		self.parent:EmitSound("Hero_LegionCommander.Duel.Victory")
	end
end

modifier_legion_commander_damage = class({})

function modifier_legion_commander_damage:IsPurgable()
	return true
end

function modifier_legion_commander_damage:IsHidden()
	return false
end

function modifier_legion_commander_damage:RemoveOnDeath()
	return false
end

function modifier_legion_commander_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_legion_commander_damage:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

modifier_legion_commander_damage_hidden = class({})

function modifier_legion_commander_damage_hidden:IsPurgable()
	return true
end

function modifier_legion_commander_damage_hidden:RemoveOnDeath()
	return false
end

function modifier_legion_commander_damage_hidden:IsHidden()
	return false
end

modifier_legion_commander_damage_permanent = class({})

function modifier_legion_commander_damage_permanent:IsPurgable()
	return true
end

function modifier_legion_commander_damage_permanent:IsHidden()
	return true
end

function modifier_legion_commander_damage_permanent:RemoveOnDeath()
	return false
end

function modifier_legion_commander_damage_permanent:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_legion_commander_damage_permanent:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end