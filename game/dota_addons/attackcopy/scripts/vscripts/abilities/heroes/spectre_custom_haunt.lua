--[[Author: Nightborn
	Date: August 27, 2016
]]

function HauntCast(keys)

	local caster = keys.caster
	local unit = caster:GetUnitName()

	local sound = keys.sound
	EmitSoundOn(sound, target)
	local ability = keys.ability
	local origin = 0

	local outgoingDamage = ability:GetSpecialValueFor( "illusion_outgoing_damage")

	local talent = caster:FindAbilityByName("special_bonus_unique_spectre_4")

    if talent and talent:GetLevel() > 0 then
        outgoingDamage = outgoingDamage + talent:GetSpecialValueFor("value")
    end
	local count = 0
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	if #targets<1 then return end
	for _,target in ipairs(targets) do
	print("heyo")
		local illusions = CreateIllusions(caster, caster, { duration = keys.duration, outgoing_damage = outgoingDamage, incoming_damage = keys.incoming_damage }, 1, 50, true, true )
		for _,illusion in ipairs(illusions) do
			origin = target:GetAbsOrigin() + RandomVector(100)
			illusion:SetForceAttackTarget(target)
			ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spectre_haunt_illusion_buff", {duration = duration})
			illusion:EmitSound("Hero_Terrorblade.Reflection")
			FindClearSpaceForUnit( illusion, origin, false )
		end

		
		count = count+1
		if count > 4 then
			break
		end
	end
	
end

function HauntSingleCast(keys)
	
	local caster = keys.caster
	local unit = caster:GetUnitName()
	local target = keys.target

	local sound = keys.sound
	EmitSoundOn(sound, target)
	local ability = keys.ability
	local origin = target:GetAbsOrigin() + RandomVector(100)

	local outgoingDamage = ability:GetSpecialValueFor( "illusion_outgoing_damage")

	local talent = caster:FindAbilityByName("special_bonus_unique_spectre_4")

    if talent and talent:GetLevel() > 0 then
        outgoingDamage = outgoingDamage + talent:GetSpecialValueFor("value")
    end
	
	local illusions = CreateIllusions(caster, caster, { duration = keys.duration, outgoing_damage = outgoingDamage, incoming_damage = keys.incoming_damage }, 1, 50, true, true )
	for _,illusion in ipairs(illusions) do
		origin = target:GetAbsOrigin() + RandomVector(100)
		illusion:SetForceAttackTarget(target)
		ability:ApplyDataDrivenModifier(caster, illusion, "modifier_spectre_haunt_illusion_buff", {duration = duration})
		illusion:EmitSound("Hero_Terrorblade.Reflection")
		FindClearSpaceForUnit( illusion, origin, false )
	end

end

function CheckScepter (keys)

	local caster = keys.caster
	local ability_haunt_single = caster:FindAbilityByName("spectre_custom_haunt_single")
	if caster:HasScepter() then
		ability_haunt_single:SetLevel(1)
		ability_haunt_single:SetHidden(false)
	else
		ability_haunt_single:SetLevel(0)
		ability_haunt_single:SetHidden(true)
	end
	local duration = caster:FindAbilityByName("spectre_custom_haunt"):GetSpecialValueFor( "duration")
	caster.haunting = true

	-- 10 second delayed, run once using gametime (respect pauses)
	Timers:CreateTimer({
		endTime = duration, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			caster.haunting = false
		end
	})

end

function LevelUpReality (keys)

	local caster = keys.caster
	local ability_reality = caster:FindAbilityByName("spectre_custom_reality")
	if ability_reality ~= nil then
		ability_reality:SetLevel(1)
	end

	caster.haunting = false

end