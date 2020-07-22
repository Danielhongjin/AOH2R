require("lib/timers")
require("lib/my")
require("lib/ai")

boss_legion_commander_revenge = class({})


function boss_legion_commander_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() or caster:IsSilenced() then
				return 0.5
			end
			caster:Purge(false, true, false, true, false)
			caster:CastAbilityNoTarget(caster:FindAbilityByName("boss_legion_commander_warpath"), -1)
		end
	)
end
