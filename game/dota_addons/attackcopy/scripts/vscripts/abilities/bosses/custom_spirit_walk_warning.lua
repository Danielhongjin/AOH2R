require("lib/timers")
require("lib/my")


custom_spirit_walk_warning = class({})


function custom_spirit_walk_warning:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	find_item(caster, "item_black_king_bar_boss"):EndCooldown()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			caster:CastAbilityOnTarget(caster, caster:FindAbilityByName("custom_spirit_walk"), -1)
		end
	)
end
