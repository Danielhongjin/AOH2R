require("lib/timers")
require("lib/my")
require("lib/ai")



local function create_strike(caster, ability, target, delay, radius, damage)
	local pos = target:GetAbsOrigin() + Vector(RandomInt(-50, 50), RandomInt(-50, 50), 0)
	local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(fx, 0, pos)
	ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
	ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
	ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
	ParticleManager:ReleaseParticleIndex(fx)
	EmitSoundOn("Hero_Invoker.SunStrike.Charge", target)
	Timers:CreateTimer(
		delay, 
		function()
			local fx = ParticleManager:CreateParticle("particles/custom/custom_mystic_flare_ambient_hit.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, pos)
			ParticleManager:SetParticleControl(fx, 1, Vector(radius, 0, 0))
			ParticleManager:ReleaseParticleIndex(fx)
			EmitSoundOn("Hero_Invoker.SunStrike.Ignite", target)
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
	local radius = ability:GetSpecialValueFor("radius")
	local totalCount = ability:GetSpecialValueFor("count")
	local interval = ability:GetSpecialValueFor("interval")
	local count = 1
	local heroes = ai_alive_heroes()
	Timers:CreateTimer(
		0,
		function()
			for _, hero in ipairs(heroes) do
				create_strike(caster, ability, hero, delay, radius, damage)
			end
			if count < totalCount then
				count = count + 1
				return interval
			end
		end
	)
	
end

