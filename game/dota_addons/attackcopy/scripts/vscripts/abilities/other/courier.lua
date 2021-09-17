require("lib/timers")

function courier_spell(keys)
	local caster = keys.caster
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_courier_invincibility", {})
end

