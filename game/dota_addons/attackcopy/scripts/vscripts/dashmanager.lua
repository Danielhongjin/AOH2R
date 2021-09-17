

if DashManager == nil then
	_G.DashManager = class({})
end


function DashManager:Init()
	CustomGameEventManager:RegisterListener("dash", Dynamic_Wrap(DashManager, "Dash"))
end

function DashManager:Dash(keys)
	local temp_vector = Vector(keys.pos["0"],keys.pos["1"], keys.pos["2"])
	for _, unit in pairs(keys.units) do
		hero = EntIndexToHScript(unit)
		if hero:IsHero() and hero:HasModifier("modifier_builtin_blink") then
			hero:FindModifierByName("modifier_builtin_blink"):Dash({pos=temp_vector})
		end
	end
end