require("lib/my")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

boss_abyssal_underlord_undead_cannon = class({})
  
function boss_abyssal_underlord_undead_cannon:OnSpellStart()	
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	local target = self:GetCursorTarget()
	caster:AddNewModifier(target, self, "modifier_boss_abyssal_underlord_undead_cannon", {duration = duration})
end

LinkLuaModifier("modifier_boss_abyssal_underlord_undead_cannon", "abilities/bosses/boss_abyssal_underlord_undead_cannon", LUA_MODIFIER_MOTION_NONE)
modifier_boss_abyssal_underlord_undead_cannon = class({})

function modifier_boss_abyssal_underlord_undead_cannon:CheckState()
	local state = {
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
	}
	return state
end

function modifier_boss_abyssal_underlord_undead_cannon:IsPurgable()
	return false
end

function modifier_boss_abyssal_underlord_undead_cannon:IsHidden()
	return false
end

function modifier_boss_abyssal_underlord_undead_cannon:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end
function modifier_boss_abyssal_underlord_undead_cannon:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduction_percent")
end
if IsServer() then
	function modifier_boss_abyssal_underlord_undead_cannon:OnCreated()
		self.parent = self:GetParent()
		self.parent:Stop()
		self.target = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent:FaceTowards(self.target:GetAbsOrigin())
		self.anim = self.parent:AddNewModifier(self.parent, self.ability, "modifier_anim", {duration = -1})
		StartAnimation(self.parent, {duration=5000, activity=ACT_DOTA_GENERIC_CHANNEL_1, rate=1})
		self.duration = self.ability:GetSpecialValueFor("duration")
		self.fx = ParticleManager:CreateParticle("particles/custom/custom_abyssal_underlord_charge_aura.vpcf", PATTACH_ABSORIGIN, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin() + Vector(0, 0, 400), true)
		ParticleManager:SetParticleControl(self.fx, 1, Vector(self.duration, 0, 0))
		
		self.fx2 = ParticleManager:CreateParticle("particles/custom/custom_abyssal_underlord_charge_beams.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin() + Vector(0, 0, 400), true)
		ParticleManager:SetParticleControl(self.fx2, 1, Vector(self.duration, 0, 0))
		self.count = self.ability:GetSpecialValueFor("damage_base")
		self:SetStackCount(self.count)
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.spawn_radius = self.ability:GetSpecialValueFor("zombie_spawn_radius")
		
		self.fx4 = ParticleManager:CreateParticle("particles/custom/abyssal_underlord_undead_cannon_tether.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx4, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx4, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin() + Vector(0, 0, 250), true)
		ParticleManager:SetParticleControl(self.fx4, 62, Vector(self.duration, 1, 0))
		
		self.fx3 = ParticleManager:CreateParticle("particles/custom/target_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx3, 0, self.parent, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.fx3, 1, Vector(self.duration, 1, 0))
		
		Timers:CreateTimer(
			0.5, 
			function()
				self.parent:EmitSoundParams("Hero_Lich.ChainFrostLoop", 0, 1.5, 0)
				AddFOWViewer(2, self.parent:GetAbsOrigin(), 1000, self.duration + 1, true)
			end
		)
		
		self:StartIntervalThink(self.interval)
	end

	function modifier_boss_abyssal_underlord_undead_cannon:OnIntervalThink()
		local zombie = CreateUnitByName("npc_boss_zombie_summon", ((Vector(RandomInt(-100, 100), RandomInt(-100, 100), 0):Normalized() * self.spawn_radius) + self.parent:GetAbsOrigin()), true, self.parent, self.parent, self.parent:GetTeamNumber())
		zombie:AddNewModifier(self.parent, self.ability, "modifier_boss_abyssal_underlord_undead_cannon_summon", {duration = self.duration - self:GetElapsedTime()})
		self.count = self:GetStackCount()
		self.parent:Stop()
		self.parent:SetForwardVector((self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized())
	end

	function modifier_boss_abyssal_underlord_undead_cannon:OnDestroy()
		if self.parent and self.parent:IsAlive() then
			self.parent:AddNewModifier(self.target, self.ability, "modifier_boss_abyssal_underlord_undead_cannon_beam", {duration = 4, damage = self.count})
		end
		StopSoundOn("Hero_Lich.ChainFrostLoop", self.parent)
		EndAnimation(self.parent)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
		ParticleManager:DestroyParticle(self.fx2, true)
		ParticleManager:ReleaseParticleIndex(self.fx2)
		ParticleManager:DestroyParticle(self.fx3, true)
		ParticleManager:ReleaseParticleIndex(self.fx3)
		ParticleManager:DestroyParticle(self.fx4, true)
		ParticleManager:ReleaseParticleIndex(self.fx4)
		if self.anim then
			self.anim:Destroy()
		end
		
		
	end
end

LinkLuaModifier("modifier_boss_abyssal_underlord_undead_cannon_beam", "abilities/bosses/boss_abyssal_underlord_undead_cannon", LUA_MODIFIER_MOTION_NONE)
modifier_boss_abyssal_underlord_undead_cannon_beam = class({})

function modifier_boss_abyssal_underlord_undead_cannon_beam:IsHidden()
	return false
end
function modifier_boss_abyssal_underlord_undead_cannon_beam:OnCreated(keys)
	self.parent = self:GetParent()
	self.target = self:GetCaster()
	self.ability = self:GetAbility()
	self.interval = self.ability:GetSpecialValueFor("interval")
	self.spawn_radius = self.ability:GetSpecialValueFor("zombie_spawn_radius")
	self.beam_delay = self.ability:GetSpecialValueFor("beam_delay")
	self.beam_radius = self.ability:GetSpecialValueFor("beam_radius")
	local damage = keys.damage
	
	if self.parent and self.target then
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
		ParticleManager:SetParticleControl(fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, self.target:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 3, Vector(self.beam_radius, self.beam_radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(self.beam_delay, 1, 1))
		ParticleManager:ReleaseParticleIndex(fx)
		StartAnimation(self.parent, {duration = self.beam_delay, activity = ACT_DOTA_CAST_ABILITY_2, rate = 1 / self.beam_delay})
		self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_anim", {duration = self.beam_delay + 1})
		Timers:CreateTimer(
			self.beam_delay, 
			function()
				if self.target:GetHealth() < damage then
					ApplyDamage({
						victim = self.target,
						attacker = self.parent,
						damage = damage,
						damage_type = self.ability:GetAbilityDamageType(),
						ability = self.ability, --Optional.
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					})
				end
				self.parent:EmitSound("Hero_Phoenix.SuperNova.Explode")
				self.target:EmitSound("Hero_Phoenix.SuperNova.Explode")
				local fx = ParticleManager:CreateParticle("particles/custom_abyssal_underlord_beam.vpcf", PATTACH_POINT, self.parent)
				ParticleManager:SetParticleControlEnt(fx, 9, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(fx, 1, self.target:GetAbsOrigin() + Vector(0, 0, 150))
				local explosion = ParticleManager:CreateParticle("particles/custom/abbysal_underlord_custom_darkrift_end.vpcf", PATTACH_POINT, self.target)
				ParticleManager:SetParticleControl(explosion, 0, self.target:GetAbsOrigin() + Vector(0, 0, 250))
				ParticleManager:SetParticleControl(explosion, 5, self.target:GetAbsOrigin() + Vector(0, 0, 250))
				ParticleManager:ReleaseParticleIndex(explosion)
				
				local explosion2 = ParticleManager:CreateParticle("particles/custom/abbysal_underlord_custom_darkrift_end.vpcf", PATTACH_POINT, self.parent)
				ParticleManager:SetParticleControl(explosion2, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 250))
				ParticleManager:SetParticleControl(explosion2, 5, self.parent:GetAbsOrigin() + Vector(0, 0, 250))
				ParticleManager:ReleaseParticleIndex(explosion2)
				
				local explosion3 = ParticleManager:CreateParticle("particles/custom/base_destruction.vpcf", PATTACH_ABSORIGIN, self.target)
				ParticleManager:SetParticleControl(explosion3, 0, self.target:GetAbsOrigin())
				ParticleManager:ReleaseParticleIndex(explosion3)
				local enemies = FindUnitsInLine(self.parent:GetTeamNumber(),
					self.parent:GetAbsOrigin(),
					self.target:GetAbsOrigin(),
					nil,
					self.beam_radius,
					DOTA_UNIT_TARGET_TEAM_BOTH,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					0
				)
				for _, enemy in ipairs(enemies) do
					ApplyDamage({
						victim = enemy,
						attacker = self.parent,
						damage = damage,
						damage_type = self.ability:GetAbilityDamageType(),
						ability = self.ability, --Optional.
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
					})
				end
				
			end
		)
		
	end
end


LinkLuaModifier("modifier_boss_abyssal_underlord_undead_cannon_summon", "abilities/bosses/boss_abyssal_underlord_undead_cannon", LUA_MODIFIER_MOTION_NONE)
modifier_boss_abyssal_underlord_undead_cannon_summon = class({})


function modifier_boss_abyssal_underlord_undead_cannon_summon:IsHidden()
	return false
end

if IsServer() then
	function modifier_boss_abyssal_underlord_undead_cannon_summon:OnCreated()
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.radius = self.ability:GetSpecialValueFor("zombie_active_radius")
		self.damage = self.ability:GetSpecialValueFor("damage_per_zombie")
		self.modifier = self.caster:FindModifierByName("modifier_boss_abyssal_underlord_undead_cannon")
		self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_burning_army_start.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControl(self.fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(self.fx)
		self:StartIntervalThink(0.1)
	end

	function modifier_boss_abyssal_underlord_undead_cannon_summon:OnIntervalThink()
		self.parent:MoveToNPC(self.caster)
		if CalcDistanceBetweenEntityOBB(self.parent, self.caster) < self.radius then
			if self.modifier then
				self.modifier:SetStackCount(self.modifier:GetStackCount() + self.damage)
			end
			self.parent:ForceKill(false)
		end
	end
	
	function modifier_boss_abyssal_underlord_undead_cannon_summon:OnDestroy()
		if self.parent then
			self.parent:ForceKill(false)
		end
	end
end


















