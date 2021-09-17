LinkLuaModifier("modifier_boss_juggernaut_counter", "abilities/bosses/boss_juggernaut_counter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vulnerable", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_generic_stunned_lua", "modifiers/modifier_generic_stunned_lua.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/my")
require("lib/timers")
boss_juggernaut_counter = class({})


function boss_juggernaut_counter:OnSpellStart()
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
			caster:AddNewModifier(caster, self, "modifier_boss_juggernaut_counter", {duration = self:GetSpecialValueFor("duration")})
		end
	)
end

modifier_boss_juggernaut_counter = class({})

function modifier_boss_juggernaut_counter:IsPurgable()
	return true
end

function modifier_boss_juggernaut_counter:IsHidden()
	return false
end

function modifier_boss_juggernaut_counter:GetStatusEffectName()
    return "particles/custom/counter_colorwarp.vpcf"
end


function modifier_boss_juggernaut_counter:StatusEffectPriority()
    return 100
end

function modifier_boss_juggernaut_counter:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
    }
end

if IsServer() then
	function modifier_boss_juggernaut_counter:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.delay = ability:GetSpecialValueFor("delay")
		self.range = ability:GetSpecialValueFor("range")
		EmitSoundOn("Hero_Antimage.Counterspell.Cast", self.parent)
		ParticleManager:CreateParticle("particles/econ/items/medusa/medusa_daughters/medusa_daughters_mana_shield_shell_impact_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		self.has_procced = false
	end
	
	function modifier_boss_juggernaut_counter:OnAttacked(keys)
		local attacker = keys.attacker
		local victim = keys.target
		if self.parent == victim and not self.has_procced then
			self.has_procced = true
			self.parent:SetCursorPosition(attacker:GetAbsOrigin())
			find_item(self.parent, "item_blink"):OnSpellStart()
			attacker:AddNewModifier(self.parent, nil, "modifier_generic_stunned_lua", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			local omnislash = self.parent:FindAbilityByName("boss_juggernaut_swift_slash")
			self.parent:SetCursorCastTarget(attacker)
			omnislash:OnSpellStart()
		end
	end
	
	function modifier_boss_juggernaut_counter:OnDestroy()
		if not self.has_procced then
			self.parent:AddNewModifier(self.parent, nil, "modifier_generic_stunned_lua", {duration = self:GetAbility():GetSpecialValueFor("vulnerable_duration")})
		end
	end
end
