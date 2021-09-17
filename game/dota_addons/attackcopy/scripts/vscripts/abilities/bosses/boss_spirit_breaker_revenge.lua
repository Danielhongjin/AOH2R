require("lib/timers")
require("lib/my")
require("lib/ai")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
boss_spirit_breaker_revenge = class({})


function boss_spirit_breaker_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local interval = self:GetSpecialValueFor("interval")
	local totalCount = self:GetSpecialValueFor("count")
	local count = 1
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local pull = caster:FindAbilityByName("boss_spirit_breaker_reverse_polarity")
	local spirits = caster:FindAbilityByName("boss_spirit_breaker_spirits")
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			if caster:IsChanneling() or caster:GetCurrentActiveAbility() ~= nil or caster:IsCommandRestricted() then
				return 0.5
			end
			caster:CastAbilityNoTarget(spirits, -1)
			pull:OnSpellStart()
			caster:AddNewModifier(caster, self, "modifier_anim", {duration = 0.5})
		end
	)
end
