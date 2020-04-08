require("lib/my")

item_ancient_janggo_2 = class({})

function item_ancient_janggo_2:GetIntrinsicModifierName()
    return "modifier_item_ancient_janggo_2_aura"
end

function item_ancient_janggo_2:OnSpellStart()
    local caster = self:GetCaster()

    caster:EmitSound("DOTA_Item.DoE.Activate")

    local units = FindUnitsInRadius(
        caster:GetTeam(), 
        caster:GetAbsOrigin(), 
        nil, 
        self:GetSpecialValueFor("aura_radius"), 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
        0, 
        0, 
        false
    )

    local duration = self:GetSpecialValueFor("duration")

    for _, unit in ipairs(units) do
        unit:AddNewModifier(caster, self, "modifier_item_ancient_janggo_2_active_buff", {
            duration = duration
        })
    end

end

LinkLuaModifier("modifier_item_ancient_janggo_2_aura", "items/item_ancient_janggo.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_ancient_janggo_2_aura = class({})



function modifier_item_ancient_janggo_2_aura:IsHidden()
    return true
end

function modifier_item_ancient_janggo_2_aura:IsPurgable()
	return false
end
function modifier_item_ancient_janggo_2_aura:IsAura()
    return true
end


function modifier_item_ancient_janggo_2_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end


function modifier_item_ancient_janggo_2_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end


function modifier_item_ancient_janggo_2_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_item_ancient_janggo_2_aura:GetModifierAura()
    return "modifier_item_ancient_janggo_2_buff"
end


function modifier_item_ancient_janggo_2_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_ancient_janggo_2_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end


function modifier_item_ancient_janggo_2_aura:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_ancient_janggo_2_aura:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_ancient_janggo_2_aura:GetModifierBonusStats_Strength()
    return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end


function modifier_item_ancient_janggo_2_aura:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end



LinkLuaModifier("modifier_item_ancient_janggo_2_buff", "items/item_ancient_janggo.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_ancient_janggo_2_buff = class({})

function modifier_item_ancient_janggo_2_buff:GetTexture()
	return "janggo_2"
end
function modifier_item_ancient_janggo_2_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end


function modifier_item_ancient_janggo_2_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("aura_movespeed")
end

function modifier_item_ancient_janggo_2_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("aura_attackspeed")
end


LinkLuaModifier("modifier_item_ancient_janggo_2_active_buff", "items/item_ancient_janggo.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_ancient_janggo_2_active_buff = class({})

function modifier_item_ancient_janggo_2_active_buff:GetTexture()
	return "janggo_2"
end
function modifier_item_ancient_janggo_2_active_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end


function modifier_item_ancient_janggo_2_active_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("active_movespeed")
end

function modifier_item_ancient_janggo_2_active_buff:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("active_attackspeed")
end
