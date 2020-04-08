
--[[
	Author: kritth
	Date: 10.01.2015.
	Reflect damage
]]
function spiked_carapace_reflect( keys )
	-- Variables
	local ability = keys.ability
	local caster = keys.caster
	local damageTaken = keys.DamageTaken
	if damageTaken > caster:GetMaxHealth() * ability:GetSpecialValueFor("min_health") * 0.01 then
		local attacker = keys.attacker

		local damageReflect = keys.ability:GetSpecialValueFor("reflect_damage")
		local damageReduce = keys.ability:GetSpecialValueFor("damage_reduce")

		local talent = caster:FindAbilityByName("special_bonus_unique_nyx")

		if talent and talent:GetLevel() > 0 then
			damageReflect = damageReflect + talent:GetSpecialValueFor("value")
		end
		local damage = damageTaken * damageReflect


		ApplyDamage({
			ability = ability,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			victim = attacker
		})
		keys.ability:ApplyDataDrivenModifier( caster, attacker, "modifier_spiked_carapaced_stun_datadriven", { } )

		caster:Heal(damageTaken * damageReduce * 0.01, caster)
		caster:RemoveModifierByName("modifier_spiked_carapace_buff_datadriven")
	end
end