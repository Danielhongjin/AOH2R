
function NetherWardZap( event )
	local caster = event.caster
	local target = event.unit 
	local ability = event.ability
	local AbilityDamageType = ability:GetAbilityDamageType()

	
	local mana_multiplier = ability:GetLevelSpecialValueFor("mana_multiplier", ability:GetLevel() - 1 )
	local health_multiplier = ability:GetLevelSpecialValueFor("mana_multiplier", ability:GetLevel() - 1 )
	local zap_mult = ability:GetSpecialValueFor("stat_penalty") * 0.01
	local stat_penalty = ability:GetSpecialValueFor("stat_penalty")
	
	local talent = caster:FindAbilityByName("special_bonus_unique_pugna_3")
	local talent2 = caster:FindAbilityByName("special_bonus_unique_pugna_6")
	if talent and talent:GetLevel() > 0 then
		stat_penalty = stat_penalty + talent:GetSpecialValueFor("value")
	end
	if talent2 and talent2:GetLevel() > 0 then
		zap_mult = zap_mult * ((100 + talent2:GetSpecialValueFor("value")) * 0.01)
	end
	
	local casterMaxHealth = caster:GetMaxHealth()
	local casterMaxMana = caster:GetMaxMana()
	
	local wards = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
    

	for _,unit in pairs(wards) do
		if unit:GetUnitLabel() == "nether_ward" then
			if caster:GetHealthPercent() > 16 then

				local zap_damage = ((casterMaxHealth * health_multiplier) + (casterMaxMana * mana_multiplier)) * zap_mult
				
				ApplyDamage({ victim = target, attacker = caster, damage = zap_damage, damage_type = AbilityDamageType })

				local attackName = "particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf" -- There are some light/medium/heavy unused versions
				local attack = ParticleManager:CreateParticle(attackName, PATTACH_ABSORIGIN_FOLLOW, unit)
				ParticleManager:SetParticleControl(attack, 1, target:GetAbsOrigin())
				
				local new_mp = caster:GetMana() - casterMaxMana * stat_penalty * 0.01
				caster:SetMana(new_mp)
				ApplyDamage({
					ability = self,
					attacker = caster,
					damage = casterMaxHealth * stat_penalty * 0.01,
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
					victim = caster,
				})
				
				target:EmitSound("Hero_Pugna.NetherWard.Target")
				caster:EmitSound("Hero_Pugna.NetherWard.Attack")
			end
		end
	end
end




--[[
	Author: Noya
	Date: April 5, 2015
	Get a point at a distance in front of the caster
]]
function GetFrontPoint( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.Distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end