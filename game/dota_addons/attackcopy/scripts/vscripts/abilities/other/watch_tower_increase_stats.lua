require("lib/my")
require("AOHGameMode")
LinkLuaModifier("modifier_dummy", "modifiers/modifier_dummy.lua", LUA_MODIFIER_MOTION_NONE)

watch_tower_increase_stats = class({})


function watch_tower_increase_stats:GetIntrinsicModifierName()
    return "modifier_watch_tower_increase_stats"
end



LinkLuaModifier("modifier_watch_tower_increase_stats", "abilities/other/watch_tower_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_watch_tower_meltdown", "abilities/other/watch_tower_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_watch_tower_stun", "abilities/other/watch_tower_increase_stats.lua", LUA_MODIFIER_MOTION_NONE )
modifier_watch_tower_increase_stats = class({})


function modifier_watch_tower_increase_stats:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then
    function modifier_watch_tower_increase_stats:OnCreated()
        self.parent = self:GetParent()
		self.parent:CastAbilityNoTarget(self.parent:FindAbilityByName("outpost_idle"), -1)
		
		local ability = self:GetAbility()
		self.health_base = ability:GetSpecialValueFor("health_base")
		self.health_per_round = ability:GetSpecialValueFor("health_per_round")
		self.armor_base = ability:GetSpecialValueFor("armor_base")
		self.armor_per_round = ability:GetSpecialValueFor("armor_per_round")
		AddAnimationTranslate(self.parent, "captured")
		self.round = 0
		
		Timers:CreateTimer(
			15,
			function()
				self.parent:SetInvulnCount(0)
				self.fx = ParticleManager:CreateParticle("particles/custom/watch_tower_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControl(self.fx, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
				ParticleManager:SetParticleControl(self.fx, 1, Vector(250, 1, 1))
				self.fx2 = ParticleManager:CreateParticle("particles/custom/watch_tower_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControl(self.fx2, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
			end
		)
		self:StartIntervalThink(3)
    end
	function modifier_watch_tower_increase_stats:OnIntervalThink()
		if self.parent and not self.parent:IsNull() and self.parent:IsAlive() then
			local round = GameRules.GLOBAL_roundNumber
			if round and round > self.round then
				
				-- Health
				local maxHealth = self.health_base + (self.health_per_round * round)
				self.parent:SetMaxHealth(maxHealth)
				self.parent:SetBaseMaxHealth(maxHealth)
				self.parent:SetHealth(maxHealth)

				-- Armor
				local armor = self.armor_base + (self.armor_per_round * round)
				self.parent:SetPhysicalArmorBaseValue(armor)
				--

				self.round = round
			end
		end
	end
	function modifier_watch_tower_increase_stats:OnTakeDamage(keys)
		local attacker = keys.attacker
		local unit = keys.unit
		if self.parent == unit and self.parent:GetHealth() < 1  then
			self.parent:SetHealth(1)
			local delay = self:GetAbility():GetSpecialValueFor("delay")
			self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_watch_tower_meltdown", {duration = delay})
			self:Destroy()
		end
	end
	
	function modifier_watch_tower_increase_stats:OnDestroy()
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
		ParticleManager:DestroyParticle(self.fx2, true)
		ParticleManager:ReleaseParticleIndex(self.fx2)
	end
	
	
end


function modifier_watch_tower_increase_stats:IsHidden()
    return true
end
function modifier_watch_tower_increase_stats:IsPurgable()
	return false
end

modifier_watch_tower_meltdown = class({})

function modifier_watch_tower_meltdown:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_watch_tower_meltdown:IsPurgable()
	return false
end
function modifier_watch_tower_meltdown:GetMinHealth()
	return 1
end
if IsServer() then
function modifier_watch_tower_meltdown:OnCreated()
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

function modifier_watch_tower_meltdown:OnIntervalThink()
	self.parent:EmitSoundParams("Hero_Invoker.Invoke", 0, 2.5, 0)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(0.6, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
end

function modifier_watch_tower_meltdown:OnDestroy()
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
			damage = target:GetHealth() * damage, 
			damage_type = DAMAGE_TYPE_PURE,
		})
		target:SetMana(0)
		if target ~= self.parent then
			target:AddNewModifier(target, nil, "modifier_watch_tower_stun", {duration = duration})
		end
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
modifier_watch_tower_stun = class({})

function modifier_watch_tower_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_watch_tower_stun:IsDebuff()
	return true
end

function modifier_watch_tower_stun:IsHidden()
	return true
end

function modifier_watch_tower_stun:IsStunDebuff()
	return true
end

function modifier_watch_tower_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_watch_tower_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_watch_tower_stun:OnCreated()
	self.parent = self:GetParent()
	self:StartIntervalThink(0.1)
end

function modifier_watch_tower_stun:OnIntervalThink()
	if self.parent then
		self.parent:SetMana(0)
	else
		self:Destroy()
	end
end
function modifier_watch_tower_stun:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_watch_tower_stun:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end