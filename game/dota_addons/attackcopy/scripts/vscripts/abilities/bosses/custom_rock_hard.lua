function rock_hard_activate(event)
	local caster = event.caster
	local ability = event.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() -1)) * 0.01
	local cooldown = ability:GetCooldown(ability:GetLevel())
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(cooldown)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_rock_hard_initial", {})
		
	end
end

function rock_hard_init(event)
	local caster = event.caster
	local ability = event.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rock_hard", {})

end

function rock_hard_damage_taken(keys)
	local caster = keys.caster
	local target = keys.attacker
	local damage = keys.DamageTaken
	
	if not target:IsMagicImmune() then
		EmitSoundOnClient("DOTA_Item.BladeMail.Damage", target:GetPlayerOwner())
		local damage_table = {
								attacker = caster,
								victim = target,
								ability = keys.ability,
								damage_type = DAMAGE_TYPE_MAGICAL,
								damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
								damage = damage
							}
		ApplyDamage(damage_table)
	end
end