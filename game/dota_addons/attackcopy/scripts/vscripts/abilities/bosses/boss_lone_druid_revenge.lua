require("lib/timers")
require("lib/my")
require("lib/ai")

boss_lone_druid_revenge = class({})


function boss_lone_druid_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local spell = caster:FindAbilityByName("boss_lone_druid_true_form")
	local summon = caster:FindAbilityByName("boss_lone_druid_spirit_bear")
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() or caster:IsStunned() then
				return 0.01
			end
			if caster.bear and IsValidEntity(caster.bear) and caster.bear:IsAlive() then
				caster.bear:CastAbilityNoTarget(caster.bear:FindAbilityByName("boss_spiritbear_inner_fire_wrapper"), -1)
			else
				summon:OnSpellStart()
			end
			caster:CastAbilityNoTarget(spell, -1)
		end
	)
end
