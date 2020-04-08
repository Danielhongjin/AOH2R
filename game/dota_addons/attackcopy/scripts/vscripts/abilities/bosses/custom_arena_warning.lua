require("lib/timers")
require("lib/timers")
require("lib/my")


custom_arena_warning = class({})


function custom_arena_warning:OnSpellStart()
	local caster = self:GetCaster()
	local health = caster:GetHealthPercent()
	if health < 40 then
		local delay = self:GetSpecialValueFor("delay")
		local radius = self:GetSpecialValueFor("radius")
		local caster_pos = caster:GetAbsOrigin()
		find_item(caster, "item_black_king_bar_boss"):CastAbility()
		find_item(caster, "item_black_king_bar_boss"):EndCooldown()
		local particle = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_wings_rope_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
		EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
		local damage = self:GetSpecialValueFor("damage")
		Timers:CreateTimer(
		delay, 
		function()
			caster:CastAbilityOnPosition(caster_pos, caster:FindAbilityByName("custom_arena"), -1)
			caster:CastAbilityOnPosition(caster_pos, caster:FindAbilityByName("custom_arena"), -1)
			local particle2 = ParticleManager:CreateParticle("particles/custom/custom_arena.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
			local damage_table = {}
			damage_table.attacker = caster
			damage_table.ability = self
			damage_table.damage_type = self:GetAbilityDamageType()
			local units = FindUnitsInRadius(caster:GetTeam(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
			for _, unit in ipairs(units) do
				damage_table.victim = unit
				damage_table.damage = damage
				ApplyDamage(damage_table)
			end
			caster:AddNewModifier(caster, nil, "modifier_custom_arena_buff", {duration = 1000})
			self:StartCooldown(20)
		end
	)
	end
	
		
end


LinkLuaModifier("modifier_custom_arena_buff", "abilities/bosses/custom_arena_warning.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_arena_buff = class({})


function modifier_custom_arena_buff:IsHidden()
    return true
end

function modifier_custom_arena_buff:GetEffectName()
	return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
end

function modifier_custom_arena_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_custom_arena_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end


function modifier_custom_arena_buff:GetModifierMoveSpeedBonus_Percentage()
    return 25
end

function modifier_custom_arena_buff:GetModifierConstantHealthRegen()
    return -100
end

function modifier_custom_arena_buff:GetModifierAttackSpeedBonus_Constant()
    return 80
end

