--[[Author: Pizzalol
	Date: 06.01.2015.
	Deals damage depending on missing hp
	If the target dies then it increases the respawn time]]
function ReapersScythe( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
	local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
	local respawn_time = ability:GetLevelSpecialValueFor("respawn_constant", (ability:GetLevel() - 1))

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = target_missing_hp * damage_per_health

	ApplyDamage(damage_table)

	-- Checking if target is alive to decide if it needs to increase respawn time
	if caster:HasScepter() and keys.target:GetHealth() > 0 then
		local percent_reduction = ability:GetSpecialValueFor("scepter_cooldown_multiplier")
		for i = 0, caster:GetAbilityCount() do
			local ability2 = caster:GetAbilityByIndex(i)
			if ability2 then
				local cooldown = ability2:GetCooldownTimeRemaining()
				if cooldown > 0 and ability ~= ability2 then
					ability2:EndCooldown()
					ability2:StartCooldown(cooldown * percent_reduction)
				end
			end
		end
		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
			local item = caster:GetItemInSlot(i)
			if item then
				cooldown = item:GetCooldownTimeRemaining()
				if item:GetCooldownTimeRemaining() > 0 then
					item:EndCooldown()
					item:StartCooldown(cooldown * percent_reduction)
				end
			end
		end
	end
end