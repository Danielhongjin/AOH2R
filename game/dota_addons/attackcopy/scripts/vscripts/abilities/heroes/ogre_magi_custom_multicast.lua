require("lib/my")
require("lib/timers")
--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Determines the multicast multiplier and applies it to the necessary spell]]
function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local used_ability = keys.event_ability
	local two_times = ability:GetLevelSpecialValueFor( "multicast_2_times", ability:GetLevel() - 1 )
	local three_times = ability:GetLevelSpecialValueFor( "multicast_3_times", ability:GetLevel() - 1 )
	local four_times = ability:GetLevelSpecialValueFor( "multicast_4_times", ability:GetLevel() - 1 )
	local talent = caster:FindAbilityByName("ogre_magi_custom_bonus_unique_1")
	local talentRisk = caster:FindAbilityByName("ogre_magi_custom_bonus_unique_2")

	if talent and talent:GetLevel() > 0 then
		four_times = four_times + talent:GetSpecialValueFor("value")
		three_times = three_times + talent:GetSpecialValueFor("value")
		two_times = two_times + talent:GetSpecialValueFor("value")
	end

	local rand = RandomInt(1,100)
	local multicast = 1
    local cursor = used_ability:GetCursorPosition()
	if rand < two_times then
		multicast = 2
	end
	if rand < three_times then
		multicast = 3
	end
	if rand < four_times then	
		multicast = 4
	end
	if multicast ~= 1 then
		local abilityName = used_ability:GetAbilityName()
		if used_ability:GetCooldown(0) > 0 and abilityName ~= "item_conduit" then
			local delay = ability:GetSpecialValueFor("interval")
			if multicast > 3 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(4, 0, 4))
				EmitSoundOn(keys.sound1, caster)
			elseif multicast == 3 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(3, 0, 2))
				EmitSoundOn(keys.sound2, caster)
			elseif multicast == 2 then
				ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_OVERHEAD_FOLLOW, caster)
				ParticleManager:SetParticleControl(ability.particle, 1, Vector(2, 0, 0))
				EmitSoundOn(keys.sound3, caster)
			end


		if ability:IsCooldownReady() and talentRisk and talentRisk:GetLevel() > 0  then
			if multicast == 1 then
				ApplyDamage({
					ability = ability,
					attacker = caster,
					damage = (caster:GetMaxHealth() * ability:GetSpecialValueFor("fail_cost") * 0.01),
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
					victim = caster,
				})
				caster:EmitSound("Hero_Alchemist.UnstableConcoction.Stun")
				local particleFail = ParticleManager:CreateParticle("particles/base_attacks/ranged_tower_bad_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

			else 
				multicast = multicast * 2
				ability_start_true_cooldown(ability)
				local particleSuccess = ParticleManager:CreateParticle("particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff_ground_ray.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			end	
		end

		
		local count = 1
		
		if abilityName ~= "ogre_magi_bloodlust" and abilityName ~= "item_health_bag_2" and abilityName ~= "item_health_bag" and abilityName ~= "item_spirit_vessel" and abilityName ~= "item_urn_of_shadows" then
			if used_ability and used_ability:GetCaster() == caster and used_ability:GetAbilityType() ~= 1 then  -- not ultimate
				Timers:CreateTimer(
					delay,
					function()
						if used_ability and caster:IsAlive() then  -- test again, object may have been deleted.
							if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
								caster:SetCursorCastTarget(keys.target)
							elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
								caster:SetCursorPosition(cursor)
							else
								caster:SetCursorTargetingNothing(true)
							end
							used_ability:OnSpellStart()
						end
						count = count + 1
						if multicast > count then 
							return delay
						end
					end
					)
				end

		else
			local targets = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				caster:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				800 + caster:GetCastRangeBonus(),	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)
			Timers:CreateTimer(
				delay,
				function()
					for _,target in pairs(targets) do
						if target ~= keys.target then
							caster:SetCursorCastTarget(target)
							used_ability:OnSpellStart()
							multicast = multicast - 1
							if multicast < 2 then
								break
							end
						end
					end
				end
			)
		end
	end
	end
end
