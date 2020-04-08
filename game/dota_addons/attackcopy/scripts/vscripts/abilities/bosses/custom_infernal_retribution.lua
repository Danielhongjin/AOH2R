function infernal_retribution(keys)
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	if ability:GetCooldownTimeRemaining() == 0 and target:IsAlive() then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
		local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() - 1)) * 0.01
		local delay = ability:GetLevelSpecialValueFor("delay", (ability:GetLevel() - 1))
		local particle = "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
		local particle_end = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
		local dummy = CreateUnitByName("npc_dummy_unit", target:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
		local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, dummy)
		EmitSoundOn("Hero_DoomBringer.Doom", target)
		
		Timers:CreateTimer(delay, function()
				local particleEndIndex = ParticleManager:CreateParticle(particle_end, PATTACH_ABSORIGIN, dummy)
				local units = FindUnitsInRadius(caster:GetTeam(), dummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
				local damage_table = {}
				damage_table.attacker = caster
				damage_table.damage_type = DAMAGE_TYPE_MAGICAL
				damage_table.ability = ability
				for _, u in ipairs(units) do
					damage_table.victim = u
					damage_table.damage = damage_pct * u:GetMaxHealth()
					ApplyDamage(damage_table)
					EmitSoundOn("Hero_Nevermore.Shadowraze.Arcana", u)
				end
				ParticleManager:DestroyParticle(particleIndex, true)
				
				dummy:ForceKill(false)
			end
		)
	end
end

function on_death(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	print("test")
	for _, u in ipairs(units) do
		u:ForceKill(true)
		print("true")
	end
end