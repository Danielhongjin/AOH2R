require("lib/my")
require("lib/popup")


item_high_tech_boots = class({})


function item_high_tech_boots:GetIntrinsicModifierName()
    return "modifier_item_high_tech_boots"
end

function item_high_tech_boots:OnSpellStart()
    local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_high_tech_boots_active", {duration = self:GetSpecialValueFor("duration")})
	caster:AddNewModifier(caster, nil, "modifier_item_high_tech_boots_effect", {duration = 1})
end

LinkLuaModifier("modifier_item_high_tech_boots_active", "items/high_tech_boots.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_high_tech_boots_active = class({})

function modifier_item_high_tech_boots_active:IsHidden()
    return false
end

function modifier_item_high_tech_boots_active:IsPurgable()
	return false
end

function modifier_item_high_tech_boots_active:GetTexture()
    return "high_tech_boots"
end


function modifier_item_high_tech_boots_active:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end

function modifier_item_high_tech_boots_active:OnCreated()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	self.speed_as_block = ability:GetSpecialValueFor("speed_as_block")
end


function modifier_item_high_tech_boots_active:GetModifierTotal_ConstantBlock(keys)
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local finalBlock = (parent:GetIdealSpeed() * self.speed_as_block)  * 0.01
	parent:AddNewModifier(parent, nil, "modifier_item_high_tech_boots_effect", {duration = 1})
	return finalBlock
end

LinkLuaModifier("modifier_item_high_tech_boots", "items/high_tech_boots.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_high_tech_boots = class({})

function modifier_item_high_tech_boots:IsHidden()
    return true
end
function modifier_item_high_tech_boots:IsPurgable()
	return false
end

function modifier_item_high_tech_boots:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_high_tech_boots:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end


function modifier_item_high_tech_boots:GetModifierMoveSpeedBonus_Special_Boots()
    return self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
end

function modifier_item_high_tech_boots:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end

function modifier_item_high_tech_boots:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end







LinkLuaModifier("modifier_item_high_tech_boots_effect", "items/high_tech_boots.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_high_tech_boots_effect = class({})

function modifier_item_high_tech_boots_effect:IsHidden()
    return true
end
function modifier_item_high_tech_boots_effect:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_item_high_tech_boots_effect:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end