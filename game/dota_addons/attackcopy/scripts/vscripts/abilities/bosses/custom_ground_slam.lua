function ground_slam_interval(event)
	local caster = event.caster
	local caster_pos = caster:GetAbsOrigin()
	local ability = event.ability
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() -1)) * 0.01
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", (ability:GetLevel() -1))
	local cast_time = 1.2
	
	if caster:HasModifier("modifier_laserbeam") == false and caster:HasModifier("modifier_pain_burst") == false and caster:HasModifier("modifier_magus_slash") == false and caster:HasModifier("modifier_arcane_whirl") == false and caster:HasModifier("modifier_arcane_whirl_pre") == false then
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType()
		EmitSoundOn("Hero_Centaur.HoofStomp", caster)
		StartAnimation(caster, {duration = cast_time, activity = ACT_DOTA_CAST_ABILITY_5, translate = "fissure"})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ground_slam_caster", {duration = cast_time})
		ability:StartCooldown(5.0)
		local particleFX = ParticleManager:CreateParticle("particles/neutral_fx/roshan_slam.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particleFX, 1, Vector(radius, 0, 0))
		local units = FindUnitsInRadius(caster:GetTeam(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _, unit in ipairs(units) do
			damage_table.victim = unit
			damage_table.damage = damage_pct * unit:GetMaxHealth()
			ApplyDamage(damage_table)
			unit:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end
	end
end