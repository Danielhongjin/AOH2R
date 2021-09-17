function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:FindAbilityByName("boss_aghanim_summon_portals"):StartCooldown(9999)
	caster:FindAbilityByName("boss_aghanim_shard_attack"):StartCooldown(9999)
	caster:FindAbilityByName("boss_aghanim_spell_swap"):StartCooldown(9999)
	local stage_1_threshold = ability:GetSpecialValueFor("stage_1")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < stage_1_threshold then
				caster:FindAbilityByName("boss_aghanim_summon_portals"):EndCooldown()
			else
				return 1
			end
		end
	)
	local stage_2_threshold = ability:GetSpecialValueFor("stage_2")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < stage_2_threshold then
				caster:FindAbilityByName("boss_aghanim_shard_attack"):EndCooldown()
			else
				return 1
			end
		end
	)
	local stage_3_threshold = ability:GetSpecialValueFor("stage_3")
	Timers:CreateTimer(
		0, 
		function()
			if caster:GetHealthPercent() < stage_3_threshold then
				caster:FindAbilityByName("boss_aghanim_spell_swap"):EndCooldown()
			else
				return 1
			end
		end
	)
end