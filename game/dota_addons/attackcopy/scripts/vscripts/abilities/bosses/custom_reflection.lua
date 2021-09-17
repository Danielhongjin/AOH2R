function Reflection( event )

	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local illusion = CreateUnitByName("npc_boss_terrorblade_clone", origin, true, caster, nil, caster:GetTeamNumber())
	illusion:EmitSound("Hero_Terrorblade.Reflection")

end

function ReflectionCast( event )

	local caster = event.caster
	local target = event.target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end