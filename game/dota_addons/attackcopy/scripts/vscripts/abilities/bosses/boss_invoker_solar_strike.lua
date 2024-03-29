require("lib/timers")
require("lib/my")
require("lib/ai")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)


local function create_strike(caster, ability, target, delay, radius, damage)
	local pos = target:GetAbsOrigin() + Vector(RandomInt(-50, 50), RandomInt(-50, 50), 0)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(fx, 0, pos)
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	target:EmitSoundParams("Hero_Invoker.SunStrike.Charge", 0, 0.5, 0)
	Timers:CreateTimer(
		delay, 
		function()
			local fx = ParticleManager:CreateParticle("particles/custom/custom_mystic_flare_ambient_hit.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(fx, 0, pos)
			ParticleManager:SetParticleControl(fx, 1, Vector(radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(fx)
			target:EmitSoundParams("Hero_Invoker.SunStrike.Ignite", 0, 0.7, 0)
			local units = FindUnitsInRadius(caster:GetTeam(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
			for _, unit in ipairs(units) do
				ApplyDamage({
					attacker = caster,
					victim = unit,
					ability = ability,
					damage_type = ability:GetAbilityDamageType(),
					damage = damage
				})
			end
		end
	)
end


function solar_strike_start(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	local delay = ability:GetSpecialValueFor("delay")
	local cast_delay = ability:GetSpecialValueFor("cast_delay")
	local radius = ability:GetSpecialValueFor("radius")
	local totalCount = ability:GetSpecialValueFor("count")
	local interval = ability:GetSpecialValueFor("interval")
	local count = 1
	local heroes = ai_alive_heroes()
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / cast_delay})
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = cast_delay})
	Timers:CreateTimer(
		cast_delay, 
		function()
			for _, hero in ipairs(heroes) do
				if hero:IsAlive() then
					create_strike(caster, ability, hero, delay, radius, damage)
				end
			end
			if count < totalCount then
				count = count + 1
				return interval
			end
		end
	)
	
end

