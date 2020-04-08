function pain_burst_start(keys)
	local caster = keys.caster
	local ability = keys.ability
	local delay = ability:GetLevelSpecialValueFor("delay", (ability:GetLevel() -1))
	local delay_add = ability:GetLevelSpecialValueFor("delay_add", (ability:GetLevel() -1))
	local hp = ( caster:GetMaxHealth() - caster:GetHealth() ) / caster:GetMaxHealth()
	local duration = delay + delay_add * hp
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_pain_burst", {duration = duration})
	StartAnimation(caster, {duration=duration, activity = ACT_DOTA_VICTORY})
	EmitSoundOn("Hero_Rubick.Telekinesis.Target", caster)
end

function pain_burst_interval(keys)
	local caster = keys.caster
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("range", (ability:GetLevel() -1))
	local range_add = ability:GetLevelSpecialValueFor("range_add", (ability:GetLevel() -1))
	local hp = ( caster:GetMaxHealth() - caster:GetHealth() ) / caster:GetMaxHealth()
	local range_total = range + range_add * hp
	local particle = "particles/econ/generic/generic_aoe_shockwave_1/generic_aoe_shockwave_1.vpcf"
	local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleIndex, 0, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(particleIndex, 1, Vector(range_total, range_total, range_total))
	ParticleManager:SetParticleControl(particleIndex, 2, Vector(1.5, 1, 1))
	ParticleManager:SetParticleControl(particleIndex, 3, Vector(80, 200, 40))
	ParticleManager:SetParticleControl(particleIndex, 4, Vector(80, 200, 40))
end

function pain_burst_activate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", ability_level)
	local damage_add = ability:GetLevelSpecialValueFor("damage_add", ability_level)
	local range = ability:GetLevelSpecialValueFor("range", ability_level)
	local range_add = ability:GetLevelSpecialValueFor("range_add", ability_level)
	local hp = (caster:GetMaxHealth() - caster:GetHealth()) / caster:GetMaxHealth()
	local damage_total = (damage_pct + damage_add * hp ) * 0.01
	local range_total = range + range_add * hp
	local particle = "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf"
	local particleIndex = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(particleIndex, 0, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(particleIndex, 1, Vector(range_total, range_total, range_total))
	ParticleManager:SetParticleControl(particleIndex, 2, Vector(2.0, 1, 1))
	ParticleManager:SetParticleControl(particleIndex, 3, Vector(80, 200, 40))
	ParticleManager:SetParticleControl(particleIndex, 4, Vector(80, 200, 40))
	EmitSoundOn("Hero_Rubick.Telekinesis.Target.Land", caster)
	EmitSoundOn("Hero_Rubick.Telekinesis.Stun", caster)
	
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, range_total, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for k, unit in ipairs(units) do
		local damage_table = {
								attacker = caster,
								victim = unit,
								ability = ability,
								damage_type = ability:GetAbilityDamageType(),
								damage = unit:GetMaxHealth() * damage_total
							}
		ApplyDamage(damage_table)
	end
end