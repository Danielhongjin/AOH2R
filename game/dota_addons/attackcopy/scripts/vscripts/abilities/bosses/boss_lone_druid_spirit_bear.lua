--[[
	Author: Noya
	Date: 15.01.2015.
	Spawns a unit with different levels of the unit_name passed
	Each level needs a _level unit inside npc_units or npc_units_custom.txt
]]
function SpiritBearSpawn( event )
	local caster = event.caster
	local ability = event.ability
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	-- Set the unit name, concatenated with the level number
	local unit_name = event.unit_name

	-- Check if the bear is alive, heals and spawns them near the caster if it is
	if caster.bear and IsValidEntity(caster.bear) and caster.bear:IsAlive() then
		FindClearSpaceForUnit(caster.bear, origin, true)
		caster.bear:SetHealth(caster.bear:GetMaxHealth())
		-- Spawn particle
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.bear)	
		
	else
		-- Create the unit and make it controllable
		caster.bear = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 1, caster.bear, PATTACH_ABSORIGIN_FOLLOW, nil, caster.bear:GetOrigin(), false)
		ParticleManager:ReleaseParticleIndex(fx)
		-- Apply the backslash on death modifier
		ability:ApplyDataDrivenModifier(caster, caster.bear, "modifier_spirit_bear", nil)
		caster.bear:AddNewModifier(caster, ability, "modifier_boss_spiritbear", {duration = -1})

	end

end

function Maul(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if caster.bear and IsValidEntity(caster.bear) and caster.bear:IsAlive() then
		FindClearSpaceForUnit(caster.bear, caster:GetAbsOrigin(), false)
		EmitSoundOn("Hero_LegionCommander.PressTheAttack", caster)
		caster.bear:AddNewModifier(target, ability, "modifier_maul", {duration = ability:GetSpecialValueFor("duration")})
		local particle = ParticleManager:CreateParticle("particles/versus/versus_explosion_burst_rings.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.bear)	
		ParticleManager:SetParticleControl(particle, 0, caster.bear:GetAbsOrigin())
	end
end


LinkLuaModifier("modifier_boss_spiritbear", "abilities/bosses/boss_lone_druid_spirit_bear.lua", LUA_MODIFIER_MOTION_NONE)
modifier_boss_spiritbear = class({})

function modifier_boss_spiritbear:IsHidden()
    return true
end
function modifier_boss_spiritbear:IsPurgable()
	return false
end

function modifier_boss_spiritbear:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_boss_spiritbear:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end
if IsServer() then
	function modifier_boss_spiritbear:OnCreated(keys)
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.lifesteal = self:GetAbility():GetSpecialValueFor("lifesteal") / 100
		self.degen = self:GetAbility():GetSpecialValueFor("bear_degen") / 100
		self.range = self:GetAbility():GetSpecialValueFor("bear_distance")
		self.interval = 0.25
		self.health = self.parent:GetMaxHealth()
		self:StartIntervalThink(self.interval)
	end
	
	function modifier_boss_spiritbear:OnIntervalThink()
		if CalcDistanceBetweenEntityOBB(self.caster, self.parent) > self.range then
			ParticleManager:CreateParticle("particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_soft.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ApplyDamage({
				victim = self.parent,
				attacker = self.caster,
				damage = self.health * self.degen * self.interval,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				ability = self.ability
			})
		end
	end
	
	function modifier_boss_spiritbear:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self.parent and CalcDistanceBetweenEntityOBB(self.caster, self.parent) < self.range then
			local heal = keys.damage * self.lifesteal	
			self.caster:Heal(heal, self.ability)
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
		end
	end
end

LinkLuaModifier("modifier_maul", "abilities/bosses/boss_lone_druid_spirit_bear.lua", LUA_MODIFIER_MOTION_NONE)
modifier_maul = class({})

function modifier_maul:IsPurgable()
	return true
end

function modifier_maul:IsHidden()
	return false
end


function modifier_maul:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_maul:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_maul:GetEffectName()
	return "particles/units/heroes/hero_life_stealer/life_stealer_open_wounds.vpcf"
end

function modifier_maul:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_maul:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_maul:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end

function modifier_maul:GetModifierModelScale()
    return 20
end

if IsServer() then
	function modifier_maul:OnCreated(keys)
		self.target = self:GetCaster()
		self.parent = self:GetParent()
		self.fx = ParticleManager:CreateParticle("particles/custom/bear_maul.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.fx, 2, Vector(self:GetAbility():GetSpecialValueFor("duration"), 1, 0))
		self:StartIntervalThink(0.25)
	end
	
	function modifier_maul:OnIntervalThink()
		if not self.target:IsMagicImmune() then
			local attackOrder = {
				UnitIndex = self.parent:entindex(), 
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = self.target:entindex()
			}
			ExecuteOrderFromTable(attackOrder)
		else
			self:Destroy()
		end
	end	
	
	function modifier_maul:OnDestroy()
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end