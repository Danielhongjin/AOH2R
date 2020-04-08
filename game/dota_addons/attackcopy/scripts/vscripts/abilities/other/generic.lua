require("lib/timers")
require("lib/my")
require("lib/ai")

local spells_aoe = {[0] = "custom_crystal_nova", 
"custom_black_hole", 
"custom_torrent",
"custom_torrent_tide",
"custom_maledict",
"custom_ice_path", --index 5
"custom_desolation",
"custom_banish",
"custom_dark_artistry",
}
local spells_target = {[0] = "custom_static_link", 
"custom_frostbite", 
"custom_mana_void", 
"custom_omni_slash_jugg", 
"custom_doom", 
"custom_lightning_bolt", --index 5
"custom_chaos_bolt", 
"custom_sunray", 
"custom_reality_rift",
"custom_primal_roar",
"custom_paralyzing_cask", --index 10
}

function generate_warning_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	
	local delay = keys.delay
	if keys.is_line and keys.is_line == 1 then
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		norm = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, norm)
		ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
	else 
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	end
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	caster:CastAbilityOnPosition(point, spell, -1)
end

function generic_aoe_noanim(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	
	if keys.is_line and keys.is_line == 1 then
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		norm = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, norm)
		ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
	else 
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	end
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnPosition(point, spell, -1)
		end
	)
end

function generic_aoe(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local delay = keys.delay
	if keys.is_line and keys.is_line == 1 then
		local norm = (point - caster:GetAbsOrigin()):Normalized()
		norm = caster:GetAbsOrigin() + norm * keys.line_length
		local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 2, norm)
		ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
		ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
	else 
		local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, point)
		ParticleManager:SetParticleControl(fx, 1, Vector(keys.radius, 1, 1))
		ParticleManager:SetParticleControl(fx, 2, Vector(keys.delay, 1, 1))
		ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	end
	local spell = caster:FindAbilityByName(spells_aoe[keys.ability_index])
	if caster:IsMoving() then
		caster:Stop()
		caster:FaceTowards(point)
	end
	StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnPosition(point, spell, -1)
		end
	)
end

function generic_target(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_target[keys.ability_index])
	target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnTarget(target, spell, -1)
		end
	)
end

function generic_target_random(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ai_random_alive_hero()
	local delay = keys.delay
	local spell = caster:FindAbilityByName(spells_target[keys.ability_index])
	target:AddNewModifier(caster, ability, "modifier_target_delay", {duration = delay})
	Timers:CreateTimer(
		delay - spell:GetCastPoint(), 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
				return 0.5
			end
			spell:EndCooldown()
			caster:CastAbilityOnTarget(target, spell, -1)
		end
	)
end

LinkLuaModifier("modifier_target_delay", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_target_delay = class({})

function modifier_target_delay:IsPurgable()
	return false
end

function modifier_target_delay:RemoveOnDeath()
	return false
end

function modifier_target_delay:IsHidden()
	return false
end

function modifier_target_delay:GetTexture()
	return "grimstroke_spirit_walk"
end

function modifier_target_delay:IsDebuff()
	return true
end

function modifier_target_delay:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_target_delay:OnCreated(keys)
	self.parent = self:GetParent()
	self.fx = ParticleManager:CreateParticle("particles/custom/target_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.fx, 1, Vector(keys.duration, 1, 0))
end

function modifier_target_delay:OnDestroy()
	self.parent = self:GetParent()
	ParticleManager:DestroyParticle(self.fx, false)
end

LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
modifier_anim = class({})

function modifier_anim:IsPurgable()
	return false
end

function modifier_anim:RemoveOnDeath()
	return false
end

function modifier_anim:IsHidden()
	return true
end

function modifier_anim:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end
