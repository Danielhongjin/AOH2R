function demons_gaze(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local check_radius = ability:GetLevelSpecialValueFor("check_radius", (ability:GetLevel() - 1))
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
	
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	local group = FindUnitsInRadius(target:GetTeam(), target:GetAbsOrigin(), target, check_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	if group[2] ~= nil then
		damage_table.damage = damage/2
		ApplyDamage(damage_table)
	else
		damage_table.damage = damage
		ApplyDamage(damage_table)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_demons_gaze_debuff", nil)
	end
end

function demons_gaze_threshold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() - 1)) * 0.01
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() - 1))
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if  ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _, u in ipairs(targets) do
			ability:ApplyDataDrivenModifier(caster, u, "modifier_demons_gaze", nil)
			EmitSoundOn("Hero_Terrorblade.Sunder.Target", u)
		end
		EmitSoundOn("Hero_Terrorblade.Sunder.Cast", caster)
	end
end