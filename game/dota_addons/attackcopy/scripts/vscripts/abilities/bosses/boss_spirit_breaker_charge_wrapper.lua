require("lib/timers")
require("lib/my")
require("lib/ai")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dummy", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_charge_lock", "abilities/bosses/boss_spirit_breaker_charge_wrapper.lua", LUA_MODIFIER_MOTION_NONE)

modifier_charge_lock = class({})

function modifier_charge_lock:IsPurgable()
	return false
end

function modifier_charge_lock:IsHidden()
	return true
end

function modifier_charge_lock:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

function modifier_charge_lock:DeclareFunctions() 
  local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
  }
  return funcs
end

function modifier_charge_lock:GetModifierStatusResistanceStacking()
	return 100
end

function charge_wrapper(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local target = keys.target
	local delay = keys.delay
	
	
	local count = 0
	local count_max = 1
	if caster:GetHealthPercent() < keys.threshold then
		count_max = 3
	end
	
	Timers:CreateTimer(
		0, 
		function()
			local point = keys.target:GetAbsOrigin()
			local norm = (point - caster:GetAbsOrigin()):Normalized()
			point = caster:GetAbsOrigin() + norm * keys.line_length
			local point_true = caster:GetAbsOrigin() + norm * (keys.line_length + keys.radius)
			local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 2, point)
			ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
			ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx)
			local spell = caster:FindAbilityByName("boss_spirit_breaker_charge_of_darkness")
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay - spell:GetCastPoint()})
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:HasModifier("modifier_anim") then
						return 0.01
					end
					caster:AddNewModifier(caster, ability, "modifier_charge_lock", {duration = keys.iteration_delay})
					AddFOWViewer(caster:GetTeamNumber(), point_true, 1000, 3, false)
					local dummy = CreateUnitByName("npc_target", point_true, false, target, target, target:GetTeamNumber())
					dummy:AddNewModifier(caster, keys.ability, "modifier_dummy", {duration = 3})
					spell:EndCooldown()
					caster:SetCursorCastTarget(dummy)
					spell:OnSpellStart()
				end
			)
			count = count + 1
			if count < count_max then
				target = ai_random_alive_hero()
				return keys.iteration_delay
			end
		end
	)
end
