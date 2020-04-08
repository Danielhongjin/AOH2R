require("lib/timers")
require("lib/my")
require("lib/ai")


local particle_start = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_team_immortal1.vpcf"
local particle_end = "particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf"


local function create_dummy(caster, ability, pos)
	local dummy = CreateUnitByName("npc_dummy_unit", pos, false, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
	return dummy
end


local function create_effect(dummy, pos, radius, effect)
	local fx = ParticleManager:CreateParticle(effect, PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(fx, 0, pos)
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 0, 0))
	return fx
end


local function dummy_with_particle(caster, ability, pos, radius, effect)
	local dummy = create_dummy(caster, ability, pos)
	local startFX = create_effect(dummy, pos, radius, effect)
	kill_if_alive(dummy)
end


local function deal_damage(caster, ability, point)
	local damage = ability:GetSpecialValueFor("damage")
	local radius = ability:GetSpecialValueFor("radius")

	local units = FindUnitsInRadius(caster:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
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


local function create_strike(caster, ability, target)
	local delay = ability:GetSpecialValueFor("delay")
	local radius = ability:GetSpecialValueFor("radius")

	local pos = target:GetAbsOrigin()

	dummy_with_particle(caster, ability, pos, radius, particle_start)

	EmitSoundOn("Hero_Invoker.SunStrike.Charge", target)

	Timers:CreateTimer(
		delay, 
		function()
			dummy_with_particle(caster, ability, pos, radius, particle_end)

			EmitSoundOn("Hero_Invoker.SunStrike.Ignite", target)

			deal_damage(caster, ability, pos)
		end
	)
end


function solar_strike_start(keys)
	local caster = keys.caster
	local ability = keys.ability

	local heroes = ai_alive_heroes()
	for _, hero in ipairs(heroes) do
		create_strike(caster, ability, hero)
	end
end

