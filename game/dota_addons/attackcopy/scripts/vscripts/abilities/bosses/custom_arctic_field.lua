function arctic_field(keys)
	local caster = keys.caster
	local ability = keys.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() - 1)) * 0.01
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		local delay = ability:GetLevelSpecialValueFor("delay", (ability:GetLevel() - 1))
		local interval = 0.4
		
		Timers:CreateTimer( function()
				explode(keys, (delay + 3.0))
				if delay > 0 then
					delay = delay - interval
					return interval
				else
					return nil
				end
			end
		)
	end
end

function explode(keys, delay)
	local caster = keys.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
	local range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() - 1))
	local particle = "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf"
	local particle_pre = "particles/units/heroes/hero_ancient_apparition/ancient_ice_vortex.vpcf"
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", (ability:GetLevel() - 1))
	local target_pos = caster_pos
	local units = FindUnitsInRadius(caster:GetTeam(), caster_pos, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
	if units[0] == nil then
		target_pos = caster_pos + RandomVector(RandomInt(0, range))
	else
		for k, unit in pairs(units) do
			target_pos = unit:GetAbsOrigin()
			break
		end
	end
	local pre_dummy = CreateUnitByName("npc_dummy_unit", target_pos, false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, pre_dummy, "modifier_dummy", {})
	local preFX = ParticleManager:CreateParticle(particle_pre, PATTACH_ABSORIGIN, pre_dummy)
	ParticleManager:SetParticleControl(preFX, 1, Vector(damage_radius, 0, 0))
	ParticleManager:SetParticleControl(preFX, 5, Vector(damage_radius, 0, 0))
	EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", pre_dummy)
	
	Timers:CreateTimer(delay, function()
			ParticleManager:DestroyParticle(preFX, false)
			local dummy = CreateUnitByName("npc_dummy_unit", target_pos, false, caster, caster, caster:GetTeamNumber())
			ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
			EmitSoundOn("Hero_Crystal.CrystalNova", dummy)
			EmitSoundOn("Hero_Crystal.CrystalNovaCast", dummy)
			local particleFX = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
			ParticleManager:SetParticleControl(particleFX, 3, Vector(damage_radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(particleFX)
			local targets = FindUnitsInRadius(caster:GetTeam(), target_pos, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
			local damage_table = {}
			damage_table.attacker = caster
			damage_table.damage = damage
			damage_table.ability = ability
			damage_table.damage_type = ability:GetAbilityDamageType()
			for k, u in ipairs(targets) do
				damage_table.victim = u
				ApplyDamage(damage_table)
			end
		end
	)
end