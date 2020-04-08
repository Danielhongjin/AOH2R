require("lib/timers")
function courier_spell(keys)
	local caster = keys.caster
	caster:SetHasInventory(true)
	Timers:CreateTimer(
		0.25, 
		function()
			caster:ForceKill(true)
		end
		)
end