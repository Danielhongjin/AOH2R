function on_toggle_upgrade(keys)
	local ability = keys.ability

	if ability:GetToggleState() then
		ability:ToggleAbility()
	end
end