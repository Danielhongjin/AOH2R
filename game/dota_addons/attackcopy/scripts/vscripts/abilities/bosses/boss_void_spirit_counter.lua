LinkLuaModifier("modifier_boss_void_spirit_counter", "abilities/bosses/boss_void_spirit_counter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/timers")
boss_void_spirit_counter = class({})


function boss_void_spirit_counter:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	caster:Stop()
	caster:AddNewModifier(caster, self, "modifier_anim", {duration = delay + self:GetSpecialValueFor("duration")})
	StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_4, rate = 1 / delay})
	caster:EmitSoundParams("Hero_VoidSpirit.Pulse.Cast", 0, 0.5, 0)
	ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	Timers:CreateTimer(
		delay, 
		function()
			caster:AddNewModifier(caster, self, "modifier_boss_void_spirit_counter", {duration = self:GetSpecialValueFor("duration")})
		end
	)
	
		
	
end

modifier_boss_void_spirit_counter = class({})

function modifier_boss_void_spirit_counter:IsPurgable()
	return true
end

function modifier_boss_void_spirit_counter:IsHidden()
	return false
end

function modifier_boss_void_spirit_counter:GetStatusEffectName()
    return "particles/custom/counter_colorwarp.vpcf"
end


function modifier_boss_void_spirit_counter:StatusEffectPriority()
    return 100
end

function modifier_boss_void_spirit_counter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
    }
end

if IsServer() then
	function modifier_boss_void_spirit_counter:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.delay = ability:GetSpecialValueFor("delay")
		self.range = ability:GetSpecialValueFor("range")
		EmitSoundOn("Hero_Antimage.Counterspell.Cast", self.parent)
		ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		self.has_procced = false
	end
	
	function modifier_boss_void_spirit_counter:OnAttacked(keys)
		local attacker = keys.attacker
		local victim = keys.target
		if self.parent == victim and not self.has_procced then
			self.has_procced = true
			local counter = self.parent:FindAbilityByName("boss_void_spirit_astral_step")
			local forward_vector = (attacker:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized()
			local point = forward_vector * self.range + self.parent:GetAbsOrigin()
			local origin = self.parent:GetAbsOrigin()
			self.parent:SetCursorPosition(point)
			counter:OnSpellStart()
			Timers:CreateTimer(
				0.25, 
				function()
					self.parent:SetCursorPosition(origin)
					counter:OnSpellStart()
					self:Destroy()
				end
			)
		end
	end
	
	function modifier_boss_void_spirit_counter:OnDestroy()
	end
end
