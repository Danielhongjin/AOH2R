require("lib/timers")
require("lib/my")
require("lib/ai")

custom_spiritbreaker_revenge = class({})


function custom_spiritbreaker_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local interval = self:GetSpecialValueFor("interval")
	local totalCount = self:GetSpecialValueFor("count")
	local count = 1
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local pull = caster:FindAbilityByName("custom_reverse_polarity")
	local spirits = caster:FindAbilityByName("custom_spirits")
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			caster:CastAbilityNoTarget(spirits, -1)
			caster:CastAbilityNoTarget(pull, -1)

		end
	)
end
