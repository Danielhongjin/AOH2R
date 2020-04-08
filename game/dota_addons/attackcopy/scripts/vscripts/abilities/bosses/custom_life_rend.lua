--[[ ============================================================================================================
	Author: Rook
	Date: January 28, 2015
	Called whenever one of Slark's autoattack lands.  If it hit an enemy hero, it steals attribute points from them 
	and leaves a counter on their modifier HUD.
	Additional parameters: keys.StatLoss
================================================================================================================= ]]
function modifier_slark_essence_shift_datadriven_on_attack_landed(keys)
	if keys.target:IsHero() and keys.target:IsOpposingTeam(keys.caster:GetTeam()) then
		--For the affected enemy, increment their visible counter modifier's stack count.
		local previous_stack_count = 0
		if keys.target:HasModifier("modifier_slark_essence_shift_datadriven_debuff") then
			previous_stack_count = keys.target:GetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff", keys.caster)
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff", nil)
			keys.target:SetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff", keys.caster, previous_stack_count + 1)

		else
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_slark_essence_shift_datadriven_debuff", nil)
			keys.target:SetModifierStackCount("modifier_slark_essence_shift_datadriven_debuff", keys.caster,1)
		end
	end
end

