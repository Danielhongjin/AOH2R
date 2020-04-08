function frozen_wasteland(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_frozen_wasteland_channel") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_frozen_wasteland_channel", nil)
	end
end