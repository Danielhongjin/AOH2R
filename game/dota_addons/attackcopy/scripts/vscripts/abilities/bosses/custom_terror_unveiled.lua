function terror_unveiled_damage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local check_radius = ability:GetLevelSpecialValueFor("check_radius", (ability:GetLevel() - 1))
	local damage_pct = ability:GetLevelSpecialValueFor("damage_pct", (ability:GetLevel() - 1)) * 0.01
	if not target:IsAncient() then
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	--local group = FindUnitsInRadius(target:GetTeam(), target:GetAbsOrigin(), target, check_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	damage = damage_pct * target:GetMaxHealth()
	--if group[2] ~= nil then
		damage_table.damage = damage/2
		ApplyDamage(damage_table)
	--else
		--damage_table.damage = damage
		--ApplyDamage(damage_table)
	--end
	--print(damage)
	end
end

function terror_unveiled_threshold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() - 1)) * 0.01
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_terror_unveiled", nil)
		ability:ApplyDataDrivenModifier(caster, caster, "thinker_terror_unveiled", nil)
		EmitSoundOn("Hero_Warlock.Upheaval", caster)
		EmitSoundOn("terrorblade_terr_movedemon_09", caster)
	end
end


	
function terror_unveiled_end(keys)
	StopSoundEvent("Hero_Warlock.Upheaval", keys.caster)
end