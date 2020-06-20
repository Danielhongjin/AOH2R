--[[Author: Pizzalol, Beaglepleaser9000
	Date: 30.12.2015.
	Takes ownership of the target unit]]
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
function HolyPersuasion( keys )

	local caster = keys.caster
	local target = keys.target
	if not target:IsConsideredHero() then
		local caster_team = caster:GetTeamNumber()
		local player = caster:GetPlayerOwnerID()
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1
		local talent = caster:FindAbilityByName("special_bonus_unique_chen_custom_2")
		
		-- Initialize the tracking data
		ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count or 0
		ability.holy_persuasion_table = ability.holy_persuasion_table or {}
		ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count or 0
		ability.holy_persuasion_ancient_table = ability.holy_persuasion_ancient_table or {}
		local has_talent = false;
		-- Ability variables
		local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)
		local max_ancients = caster:FindAbilityByName("chen_hand_of_god"):GetLevel()
		local units = FindUnitsInRadius(
					DOTA_TEAM_GOODGUYS,
					target:GetAbsOrigin(),
					nil,
					ability:GetSpecialValueFor("talent_radius"),
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
					0,
					false
				)
		if talent and talent:GetLevel() > 0 then
			max_units = max_units + talent:GetSpecialValueFor("value")
			has_talent = true
				
		end

		-- Change the ownership of the unit and restore its mana to full
		if not target:IsAncient() and not has_talent or caster:HasScepter() and caster:FindAbilityByName("chen_hand_of_god"):GetLevel() > 0 and target:IsAncient() then
			target:SetTeam(caster_team)
			target:SetOwner(caster)
			target:SetControllableByPlayer(player, true)
			target:GiveMana(target:GetMaxMana())
			target:SetBaseMagicalResistanceValue(target:GetBaseMagicalResistanceValue() + (100 - target:GetBaseMagicalResistanceValue()) * 0.01 * ability:GetSpecialValueFor("magic_resistance"))
			ability:ApplyDataDrivenModifier(caster, target, "modifier_chen_custom_holy_persuasion_buff", {duration = -1})
			FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
			target:AddNewModifier(target, nil, "modifier_summonbuff", {id = caster:GetPlayerID()})
			-- Track the unit
			if target:IsAncient() then
				ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count + 1
				table.insert(ability.holy_persuasion_ancient_table, target)

				-- If the maximum amount of units is reached then kill the oldest unit
				if ability.holy_persuasion_ancient_unit_count > max_ancients then
					ability.holy_persuasion_ancient_table[1]:ForceKill(true) 
				end
			else
				ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
				table.insert(ability.holy_persuasion_table, target)

				-- If the maximum amount of units is reached then kill the oldest unit
				if ability.holy_persuasion_unit_count > max_units then
					ability.holy_persuasion_table[1]:ForceKill(true) 
				end
			end
		else
			for _,target2 in ipairs(units) do
				if not target2:IsAncient() then
					target2:SetTeam(caster_team)
					target2:SetOwner(caster)
					target2:SetControllableByPlayer(player, true)
					target2:AddNewModifier(target2, nil, "modifier_summonbuff", {id = caster:GetPlayerID()})
					target2:GiveMana(target:GetMaxMana())
					target2:SetBaseMagicalResistanceValue(target2:GetBaseMagicalResistanceValue() + (100 - target2:GetBaseMagicalResistanceValue()) * 0.01 * ability:GetSpecialValueFor("magic_resistance"))
					ability:ApplyDataDrivenModifier(caster, target2, "modifier_chen_custom_holy_persuasion_buff", {duration = -1})
					FindClearSpaceForUnit( target2, target2:GetAbsOrigin(), true )
					-- Track the unit
					ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count + 1
					table.insert(ability.holy_persuasion_table, target2)

					-- If the maximum amount of units is reached then kill the oldest unit
					if ability.holy_persuasion_unit_count > max_units then
						ability.holy_persuasion_table[1]:ForceKill(true) 
					end
				end
			
			end
		end
	end
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function HolyPersuasionRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	if target:IsAncient() then
		for i = 1, #ability.holy_persuasion_ancient_table do
			if ability.holy_persuasion_ancient_table[i] == target then
				table.remove(ability.holy_persuasion_ancient_table, i)
				ability.holy_persuasion_ancient_unit_count = ability.holy_persuasion_ancient_unit_count - 1
				break
			end
		end
	else
		for i = 1, #ability.holy_persuasion_table do
			if ability.holy_persuasion_table[i] == target then
				table.remove(ability.holy_persuasion_table, i)
				ability.holy_persuasion_unit_count = ability.holy_persuasion_unit_count - 1
				break
			end
		end
	end
end