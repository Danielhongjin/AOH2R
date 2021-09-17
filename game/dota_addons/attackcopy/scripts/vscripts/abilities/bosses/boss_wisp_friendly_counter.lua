require("lib/ai")
LinkLuaModifier("modifier_boss_wisp_friendly_counter", "abilities/bosses/boss_wisp_friendly_counter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_meltdown", "abilities/bosses/boss_wisp_friendly_counter", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy", "modifiers/modifier_dummy.lua", LUA_MODIFIER_MOTION_NONE)

boss_wisp_friendly_counter = class({})

function boss_wisp_friendly_counter:GetIntrinsicModifierName()
	return "modifier_boss_wisp_friendly_counter"
end

modifier_boss_wisp_friendly_counter = class({})

function modifier_boss_wisp_friendly_counter:IsHidden()
	return true
end
if IsServer() then
	
	function modifier_boss_wisp_friendly_counter:DeclareFunctions()
		local funcs = {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
		}
		return funcs
	end
	
	function modifier_boss_wisp_friendly_counter:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.degen_rate = self.ability:GetSpecialValueFor("degen_rate") * 0.01
		self.degen_time = self.ability:GetSpecialValueFor("degen_time")
		self.combat_timer = 0
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.cooldown = self.ability:GetSpecialValueFor("cooldown")
		self.counter = self.parent:FindAbilityByName("boss_wisp_friendly_deafening_blast")
		self.pull = self.parent:FindAbilityByName("boss_wisp_friendly_electric_vortex_wrapper")
		self:StartIntervalThink(self.interval)
	end

	function modifier_boss_wisp_friendly_counter:OnIntervalThink()
		if self.pull:IsCooldownReady() then
			self.parent:SetCursorCastTarget(ai_random_alive_hero())
			self.pull:OnSpellStart()
			self.pull:UseResources(false, false, true)
		end
		self.combat_timer = self.combat_timer + self.interval
		if self.combat_timer > self.degen_time then
			ApplyDamage({
				victim = self.parent,
				attacker = self.parent,
				damage = self.parent:GetMaxHealth() * self.degen_rate * self.interval,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				ability = self.ability,
			})
		end
	end

	function modifier_boss_wisp_friendly_counter:OnTakeDamage(keys)
		local attacker = keys.attacker
		local unit = keys.unit
		if self.parent == unit then
			if self.parent:GetHealth() < 1 then
				self.parent:SetHealth(1)
				local delay = self:GetAbility():GetSpecialValueFor("duration")
				self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_wisp_meltdown", {duration = delay})
				self:Destroy()
			elseif attacker ~= unit then
				self.combat_timer = 0
				if self.ability:IsCooldownReady() and not attacker:IsBuilding() then
					self.parent:SetCursorCastTarget(attacker)
					self.counter:OnSpellStart()
					self.ability:StartCooldown(self.cooldown)
				end
			end
		end
	end
end


modifier_wisp_meltdown = class({})

function modifier_wisp_meltdown:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_wisp_meltdown:IsPurgable()
	return false
end
function modifier_wisp_meltdown:GetMinHealth()
	return 1
end
if IsServer() then
function modifier_wisp_meltdown:OnCreated()
	self.parent = self:GetParent()
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self.parent:CastAbilityNoTarget(self.parent:FindAbilityByName("outpost_channel"), -1)
	self.emp_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(self.emp_effect)
	self.dummy = create_dummy(self.parent, self.parent:GetAbsOrigin() + Vector(0, 0, 200))
	self.dummy:AddNewModifier(self.dummy, nil, "modifier_dummy", {})
	self.dummy:SetOrigin(self.parent:GetAbsOrigin() + Vector(0, 0, 200))
	EmitSoundOn("Hero_Invoker.EMP.Cast", self.dummy)
	self:StartIntervalThink(0.6)
end

function modifier_wisp_meltdown:OnIntervalThink()
	StartAnimation(self.parent, {duration = 0.25, activity = ACT_DOTA_ATTACK, rate = 1})
	self.parent:EmitSoundParams("Hero_Invoker.Invoke", 0, 2.5, 0)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(0.6, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
end

function modifier_wisp_meltdown:OnDestroy()
	local ability = self:GetAbility()
	local delay = ability:GetSpecialValueFor("delay")
	local damage = ability:GetSpecialValueFor("damage") * 0.01
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local pos = self.parent:GetAbsOrigin()
	EmitSoundOn("Hero_Invoker.SunStrike.Ignite.Apex", self.dummy)
	EmitSoundOn("Hero_Invoker.EMP.Discharge", self.dummy)
	EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Complete", self.dummy)
	local fx = ParticleManager:CreateParticle("particles/custom/abbysal_underlord_custom_darkrift_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.dummy)
	ParticleManager:SetParticleControl(fx, 0, self.dummy:GetAbsOrigin() + Vector(0, 0, 200))
	ParticleManager:SetParticleControl(fx, 5, self.dummy:GetAbsOrigin() + Vector(0, 0, 200))
	ParticleManager:ReleaseParticleIndex(fx)
	local emp_explosion_effect = ParticleManager:CreateParticle("particles/custom/custom_emp_explode.vpcf",  PATTACH_ABSORIGIN, self.dummy)
	local emp_explosion_distortion = ParticleManager:CreateParticle("particles/custom/watch_tower_detonation_distortion.vpcf",  PATTACH_ABSORIGIN, self.dummy)
	Timers:CreateTimer(
		0.25, 
		function()
			local emp_explosion_distortion = ParticleManager:CreateParticle("particles/custom/watch_tower_detonation_distortion.vpcf",  PATTACH_ABSORIGIN, self.dummy)
		end
	)
	Timers:CreateTimer(
		0.5, 
		function()
			local emp_explosion_distortion = ParticleManager:CreateParticle("particles/custom/watch_tower_detonation_distortion.vpcf",  PATTACH_ABSORIGIN, self.dummy)
		end
	)
	Timers:CreateTimer(
		0.75, 
		function()
			local emp_explosion_distortion = ParticleManager:CreateParticle("particles/custom/watch_tower_detonation_distortion.vpcf",  PATTACH_ABSORIGIN, self.dummy)
		end
	)
	
	ParticleManager:ReleaseParticleIndex(emp_explosion_effect)
	local enemies = FindUnitsInRadius(self.parent:GetTeam(), 
		pos, 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		FIND_ANY_ORDER, 
		false
	)
	for _, target in ipairs(enemies) do
		ApplyDamage({
			victim = target, 
			attacker = target, 
			damage = target:GetMaxHealth() * damage, 
			damage_type = DAMAGE_TYPE_PURE,
		})
	end
	Timers:CreateTimer(
		4, 
		function()
			self.dummy:ForceKill(false)
		end
	)
	self.parent:ForceKill(false)
end
end