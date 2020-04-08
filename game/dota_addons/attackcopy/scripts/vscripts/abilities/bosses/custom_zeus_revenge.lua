require("lib/ai")
custom_zeus_revenge = class({})

function custom_zeus_revenge:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	find_item(caster, "item_black_king_bar_boss"):CastAbility()
	find_item(caster, "item_black_king_bar_boss"):EndCooldown()
	local particle = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova_g2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) 
	EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
	local target = ai_weakest_alive_hero_current()
	target:AddNewModifier(caster,self, "modifier_custom_zeus_revenge_debuff", {duration = self:GetSpecialValueFor("delay")})
	Timers:CreateTimer(
		delay, 
		function()
			EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
			caster:CastAbilityOnTarget(target, caster:FindAbilityByName("custom_greased_lightning"),  -1)
			target:AddNewModifier(target,self, "modifier_custom_zeus_revenge_buff", {duration = self:GetSpecialValueFor("buff_duration")})
		end
	)
end

LinkLuaModifier("modifier_custom_zeus_revenge_debuff", "abilities/bosses/custom_zeus_revenge.lua", LUA_MODIFIER_MOTION_NONE)
modifier_custom_zeus_revenge_debuff = class({})

function modifier_custom_zeus_revenge_debuff:IsPurgable()
	return false
end

function modifier_custom_zeus_revenge_debuff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end
function modifier_custom_zeus_revenge_debuff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end
function modifier_custom_zeus_revenge_debuff:GetEffectName()
	return "particles/items_fx/chain_lightning.vpcf"
end
function modifier_custom_zeus_revenge_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_custom_zeus_revenge_debuff:OnCreated()
	self.parent = self:GetParent()
	self.caster = self:GetAbility():GetCaster()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning_sphere_sparks.vpcf", PATTACH_POINT, self.caster)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end
function modifier_custom_zeus_revenge_debuff:OnDestroy()
	ParticleManager:DestroyParticle(self.particle,  true)
end

LinkLuaModifier("modifier_custom_zeus_revenge_buff", "abilities/bosses/custom_zeus_revenge.lua", LUA_MODIFIER_MOTION_NONE)
modifier_custom_zeus_revenge_buff = class({})

function modifier_custom_zeus_revenge_buff:IsPurgable()
	return false
end

function modifier_custom_zeus_revenge_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_custom_zeus_revenge_buff:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("movespeed_buff")
end

function modifier_custom_zeus_revenge_buff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen_buff")
end

function modifier_custom_zeus_revenge_buff:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("health_regen_buff")
end

function modifier_custom_zeus_revenge_buff:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_buff")
end

function modifier_custom_zeus_revenge_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attackspeed_buff")
end


function modifier_custom_zeus_revenge_buff:OnCreated()
	self.parent = self:GetParent()
	self.caster = self:GetAbility():GetCaster()
	self.particle = ParticleManager:CreateParticle("particles/econ/events/ti9/mjollnir_shield_ti9_beam_zap.vpcf", PATTACH_POINT, self.caster)
	ParticleManager:SetParticleControlEnt(self.particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end
function modifier_custom_zeus_revenge_buff:OnDestroy()
	ParticleManager:DestroyParticle(self.particle,  true)
end

