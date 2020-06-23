require("lib/timers")

function courier_spell(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_courier_invincibility", {})
end

function courier_moveto(keys)
	local caster = keys.caster
	Timers:CreateTimer(
		0.5, 
		function()
			caster:SetAbsOrigin(Vector(-6000,-6000,0))
		end
	)
	
end