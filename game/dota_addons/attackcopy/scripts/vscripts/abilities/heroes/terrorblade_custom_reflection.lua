--[[Author: Noya
	Date: 11.01.2015.
	Creates an unselectable, uncontrollable and invulnerable illusion at the back of the target
]]
function Reflection( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local illusions = CreateIllusions(caster, caster, { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = 0 }, 1, 50, true, true )
	for _,illusion in ipairs(illusions) do
		origin = target:GetAbsOrigin() + RandomVector(100)
		illusion:SetForceAttackTarget(target)
		ability:ApplyDataDrivenModifier(caster, illusion, "modifier_reflection_invulnerability", nil)
		illusion:EmitSound("Hero_Terrorblade.Reflection")
		FindClearSpaceForUnit( illusion, origin, false )
	end
end

--[[Author: Noya
	Date: 11.01.2015.
	Shows the Cast Particle, which for TB is originated between each weapon, in here both bodies are linked because not every hero has 2 weapon attach points
]]
function ReflectionCast( event )

	local caster = event.caster
	local target = event.target
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"

	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
end