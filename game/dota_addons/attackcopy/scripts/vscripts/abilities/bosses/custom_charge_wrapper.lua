require("lib/timers")
require("lib/my")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

function charge_wrapper(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target:GetAbsOrigin()
	local target = keys.target
	local delay = keys.delay
	local norm = (point - caster:GetAbsOrigin()):Normalized()
	point = caster:GetAbsOrigin() + norm * keys.line_length
	local point_true = caster:GetAbsOrigin() + norm * (keys.line_length + keys.radius)
	
	Timers:CreateTimer(
		0, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			print("break 1")
			local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 1, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(fx, 2, point)
			ParticleManager:SetParticleControl(fx, 3, Vector(keys.radius, keys.radius, 1))
			ParticleManager:SetParticleControl(fx, 4, Vector(keys.delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx)
			local spell = caster:FindAbilityByName("custom_charge_of_darkness")
			if caster:IsMoving() then
				caster:Stop()
				caster:FaceTowards(point)
			end
			print("break 2")
			StartAnimation(caster, {duration = keys.anim_duration, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / keys.anim_duration})
			caster:AddNewModifier(caster, ability, "modifier_anim", {duration = anim_duration})
			print("break 3")
			Timers:CreateTimer(
				delay - spell:GetCastPoint(), 
				function()
					if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil then
						return 0.5
					end
					AddFOWViewer(caster:GetTeamNumber(), point_true, 100, 2, false)
					local dummy = CreateUnitByName("npc_target", point_true, false, target, target, target:GetTeamNumber())
					dummy:AddNewModifier(caster, keys.ability, "modifier_dummy", {})
					spell:EndCooldown()
					caster:CastAbilityOnTarget(dummy, spell, -1)
					caster:AddNewModifier(caster, ability, "modifier_anim", {duration = 1})
				end
			)
		end
	)
end

LinkLuaModifier("modifier_dummy", "abilities/bosses/custom_charge_wrapper.lua", LUA_MODIFIER_MOTION_NONE)
modifier_dummy = class({})

function modifier_dummy:IsPurgable()
	return false
end

function modifier_dummy:RemoveOnDeath()
	return false
end

function modifier_dummy:IsHidden()
	return true
end

function modifier_dummy:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end
if IsServer() then
	function modifier_dummy:OnCreated()
		local parent = self:GetParent()
		Timers:CreateTimer(
			3, 
			function()
				parent:ForceKill(false)
			end
		)
	end
end