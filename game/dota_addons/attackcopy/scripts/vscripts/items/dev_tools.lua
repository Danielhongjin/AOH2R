function manafill(keys)
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300  --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	
	keys.caster:EmitSound("DOTA_Item.Dagon.Activate")
	keys.target:EmitSound("DOTA_Item.Dagon5.Target")
		
	keys.target:SetMana(keys.target:GetMaxMana())
end

function damage25(keys)
	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300  --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
	
	keys.caster:EmitSound("DOTA_Item.Dagon.Activate")
	keys.target:EmitSound("DOTA_Item.Dagon5.Target")
	ApplyDamage({
		attacker = keys.caster,
		victim = keys.target,
		ability = nil,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
		damage = keys.target:GetMaxHealth() * 0.25
	})
end