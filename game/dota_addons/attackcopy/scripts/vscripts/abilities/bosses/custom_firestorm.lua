require("lib/my")
require("lib/ai")

function firestorm(keys)
	local caster = keys.caster
	local ability = keys.ability
	local firestorm = caster:FindAbilityByName("custom_pit")
	print("firestorm here im fucking shit up")
	local heroes = ai_alive_heroes()
	for _, hero in ipairs(heroes) do
		caster:CastAbilityOnPosition(hero:GetAbsOrigin(), firestorm, -1)
	end
end