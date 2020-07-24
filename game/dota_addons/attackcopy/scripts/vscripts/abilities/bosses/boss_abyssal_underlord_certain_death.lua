require("lib/ai")
require("lib/my")
LinkLuaModifier("modifier_target_delay", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
boss_abyssal_underlord_certain_death = class({})


function boss_abyssal_underlord_certain_death:OnSpellStart()
	local caster = self:GetCaster()
	local heroes = ai_alive_heroes()
	local delay = self:GetSpecialValueFor("delay")
	if #heroes ~= 0 then
		StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
		caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
		for _, hero in ipairs(heroes) do
			hero:AddNewModifier(caster, self, "modifier_target_delay", {duration = delay})
		end
		Timers:CreateTimer(
			delay, 
			function()
				EmitSoundOn("Hero_Bane.Nightmare", caster)
				for _, hero in ipairs(heroes) do
					local orb = CreateUnitByName("npc_death_orb", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
					orb:AddNewModifier(
						hero,
						self,
						"modifier_boss_abyssal_underlord_certain_death_behavior",
						{duration = self:GetSpecialValueFor("duration")}
					)
				end
			end
		)
	end
end

LinkLuaModifier("modifier_boss_abyssal_underlord_certain_death_behavior", "abilities/bosses/boss_abyssal_underlord_certain_death.lua", LUA_MODIFIER_MOTION_NONE)
modifier_boss_abyssal_underlord_certain_death_behavior = class({})

function modifier_boss_abyssal_underlord_certain_death_behavior:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end

function modifier_boss_abyssal_underlord_certain_death_behavior:IsHidden()
    return true
end

function modifier_boss_abyssal_underlord_certain_death_behavior:IsPurgable()
	return false
end

function modifier_boss_abyssal_underlord_certain_death_behavior:OnCreated()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.target = self:GetCaster()
	EmitSoundOn("Hero_Bane.Nightmare.Loop", self.target)
	self.fx = ParticleManager:CreateParticle("particles/custom/certain_death_smoke.vpcf", PATTACH_POINT_FOLLOW, self.parent)
	self.fx2 = ParticleManager:CreateParticle("particles/custom/bear_maul.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.fx2, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.fx2, 2, Vector(self:GetAbility():GetSpecialValueFor("duration"), 1, 0))
	ParticleManager:SetParticleControlEnt(self.fx, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	
	
	self:StartIntervalThink(0.25)
end

function modifier_boss_abyssal_underlord_certain_death_behavior:OnIntervalThink()
	self.parent:MoveToNPC(self.target)
end

function modifier_boss_abyssal_underlord_certain_death_behavior:IsAura()
    return true
end


function modifier_boss_abyssal_underlord_certain_death_behavior:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("radius")
end


function modifier_boss_abyssal_underlord_certain_death_behavior:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end


function modifier_boss_abyssal_underlord_certain_death_behavior:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_boss_abyssal_underlord_certain_death_behavior:GetModifierAura()
    return "modifier_boss_abyssal_underlord_certain_death_debuff"
end

function modifier_boss_abyssal_underlord_certain_death_behavior:OnDestroy()
	StopSoundOn("Hero_Bane.Nightmare.Loop", self.target)
	ParticleManager:DestroyParticle(self.fx, false)
	ParticleManager:DestroyParticle(self.fx2, false)
	self.parent:ForceKill(false)
end


LinkLuaModifier("modifier_boss_abyssal_underlord_certain_death_debuff", "abilities/bosses/boss_abyssal_underlord_certain_death.lua", LUA_MODIFIER_MOTION_NONE)
modifier_boss_abyssal_underlord_certain_death_debuff = class({})

function modifier_boss_abyssal_underlord_certain_death_debuff:IsHidden()
    return true
end

function modifier_boss_abyssal_underlord_certain_death_debuff:IsPurgable()
	return false
end

function modifier_boss_abyssal_underlord_certain_death_debuff:OnCreated()
	self.parent = self:GetParent()
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.interval = self.ability:GetSpecialValueFor("interval")
	self:StartIntervalThink(self.interval)
end

function modifier_boss_abyssal_underlord_certain_death_debuff:OnIntervalThink()
	ApplyDamage({
		victim = self.parent,
		attacker = self.caster,
		damage = self.damage * self.interval,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	})
end





