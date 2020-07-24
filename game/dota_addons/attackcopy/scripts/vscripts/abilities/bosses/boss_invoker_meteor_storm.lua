require("lib/timers")
require("lib/my")
require("lib/ai")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
boss_invoker_meteor_storm = class({})

function boss_invoker_meteor_storm:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local position = target:GetAbsOrigin()
	local caster_origin = caster:GetAbsOrigin()
	local delay = self:GetSpecialValueFor("delay")
	local total = self:GetSpecialValueFor("count")
	local spread = self:GetSpecialValueFor("spread")
	local count = 1
	-- Chaos Meteor stats
	local meteor = caster:FindAbilityByName("boss_invoker_chaos_meteor")
	local radius = meteor:GetSpecialValueFor("area_of_effect")
	local distance = meteor:GetSpecialValueFor("travel_distance")
	local land_time = meteor:GetSpecialValueFor("land_time")
	local exort = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_apex_exort_orb.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(exort, 1, caster:GetAbsOrigin() + Vector(0, 0, 400))
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = total * 0.2})
	Timers:CreateTimer(
		0, 
		function()
			local pos = position + Vector(RandomInt(-spread, spread), RandomInt(-spread, spread), 0)
			
			caster:CastAbilityOnPosition(pos, meteor, -1)
			
			local forward_vector = (Vector(pos.x, pos.y, 0) - Vector(caster_origin.x, caster_origin.y, 0)):Normalized()
			local end_pos = forward_vector * distance + caster_origin
			local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster_origin)
			ParticleManager:SetParticleControl(fx, 1, pos)
			ParticleManager:SetParticleControl(fx, 2, end_pos)
			ParticleManager:SetParticleControl(fx, 3, Vector(radius, radius, 1))
			ParticleManager:SetParticleControl(fx, 4, Vector(delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx)
			
			local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, pos)
			ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
			ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
			ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
			ParticleManager:ReleaseParticleIndex(fx)
			
			local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_origin, true)
			ParticleManager:SetParticleControl(fx2, 1, pos)
			ParticleManager:SetParticleControl(fx2, 2, Vector(delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx2)
			if count < total then
				count = count + 1
				return 0.2
			end
		end
	)
	Timers:CreateTimer(
		2, 
		function()
			ParticleManager:DestroyParticle(exort, true)
			ParticleManager:ReleaseParticleIndex(exort)
		end
	)
end
