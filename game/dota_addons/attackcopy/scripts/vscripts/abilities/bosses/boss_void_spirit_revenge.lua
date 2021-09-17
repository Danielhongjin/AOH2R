require("lib/timers")
require("lib/my")
require("lib/ai")

boss_void_spirit_revenge = class({})


function boss_void_spirit_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local spell = caster:FindAbilityByName("boss_void_spirit_pentagram")
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	if caster:IsMoving() then
		caster:Stop()
	end
	StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_1, rate = 1 / delay})
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = delay})
	spell:OnSpellStart()
end
