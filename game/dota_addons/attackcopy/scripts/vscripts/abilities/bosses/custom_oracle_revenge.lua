
require("lib/my")
require("lib/ai")

custom_oracle_revenge = class({})

if IsServer() then
	function custom_oracle_revenge:OnSpellStart()
		local caster = self:GetCaster()
		find_item(caster, "item_black_king_bar_boss"):CastAbility()
		local kinetic = caster:FindAbilityByName("custom_kinetic_field")
		local flare = caster:FindAbilityByName("custom_mystic_flare_wrapper")
		local target = self:GetCursorPosition()
		flare:EndCooldown()
		caster:SetCursorPosition(target)
		kinetic:OnSpellStart()
		caster:CastAbilityOnPosition(target, flare, -1)
	end
end