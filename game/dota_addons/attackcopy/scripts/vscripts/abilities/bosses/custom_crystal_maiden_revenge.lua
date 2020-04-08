require("lib/timers")
require("lib/my")
require("lib/ai")
require("abilities/other/generic")

custom_crystal_maiden_revenge = class({})


function custom_crystal_maiden_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	local interval = self:GetSpecialValueFor("interval")
	local totalCount = self:GetSpecialValueFor("count")
	local count = 1
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	local ice = caster:FindAbilityByName("custom_ice_path_wrapper")
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	Timers:CreateTimer(
		delay, 
		function()
			caster:AddNewModifier(caster, self, "modifier_anim", {duration = totalCount * interval})
			StartAnimation(caster, {duration = totalCount * interval, activity = ACT_DOTA_CAST_ABILITY_4})
			Timers:CreateTimer(
				0, 
				function()
					caster:SetCursorPosition(ai_random_alive_hero():GetAbsOrigin())
					ice:OnSpellStart()
					count = count + 1
					if count < totalCount then
						return interval
					else
						return nil
					end
				end
			)
		end
	)
end
