--[[Author: YOLOSPAGHETTI
	Date: February 17, 2016
	Applies the damage to the target]]
function ApplyDPS(keys)
	
	if keys.caster then
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local health_percent = ability:GetSpecialValueFor("damage_percent") / 100 * ability:GetSpecialValueFor("tick_rate")
	local health = target:GetMaxHealth()
	
	ApplyDamage({victim = target, attacker = caster, damage = health * health_percent, damage_type = ability:GetAbilityDamageType()})
	end
end