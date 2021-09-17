require("lib/my")
require("lib/timers")


boss_void_spirit_dissimilate_wrapper = class({})

function boss_void_spirit_dissimilate_wrapper:OnSpellStart(keys)
	local caster = self:GetCaster()
	local spell = caster:FindAbilityByName("boss_void_spirit_dissimilate")
	local point = caster:GetCursorCastTarget():GetAbsOrigin()
	
	caster:CastAbilityNoTarget(spell, -1)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(fx, 0, point)
	ParticleManager:SetParticleControl(fx, 1, Vector(250, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(1, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	Timers:CreateTimer(
		0.3,
		function()
			print(point)
			caster:MoveToPosition(point)
		end
	)
end

