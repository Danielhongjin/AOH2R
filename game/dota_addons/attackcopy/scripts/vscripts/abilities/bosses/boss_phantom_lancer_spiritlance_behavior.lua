boss_phantom_lancer_spiritlance_behavior = class({})


function boss_phantom_lancer_spiritlance_behavior:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		2000,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetAbsOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		2000,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	local target = nil
	if enemies[0] ~= nil then
		target =  enemies[0]
	else
		target =  enemies[1]
	end

	for _, ally in pairs(allies) do
		if ally:HasAbility("boss_phantom_lancer_spiritlance_wrapper") then
			local spell = ally:FindAbilityByName("boss_phantom_lancer_spiritlance_wrapper")
			ally:CastAbilityOnPosition(target:GetAbsOrigin() + Vector(RandomInt(-200, 200), RandomInt(-200, 200), 0), spell, caster:GetPlayerOwnerID())
		end
	end
	
		
	
end
