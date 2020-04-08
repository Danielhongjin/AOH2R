function eruption_start(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() - 1))
	local distance = ability:GetLevelSpecialValueFor("distance", (ability:GetLevel() - 1))
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local interval = 0.5
	local i = interval
	Timers:CreateTimer(function()
			caster.damage = caster.damage + 200
			i = i + interval
			if (i < distance/speed) then
				return interval
			else
				return nil
			end
		end
	)
end

function eruption_damage(keys)
	local caster = keys.caster
	local damage_table = {
		attacker = caster,
		victim = keys.target,
		ability = keys.ability,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = caster.damage
	}
	ApplyDamage(damage_table)
end