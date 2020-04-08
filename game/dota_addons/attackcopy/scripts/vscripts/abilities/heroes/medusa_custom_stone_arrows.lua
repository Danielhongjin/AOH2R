

medusa_custom_stone_arrows = class({})

function medusa_custom_stone_arrows:GetIntrinsicModifierName()
    return "modifier_medusa_custom_stone_arrows"
end



LinkLuaModifier("modifier_medusa_custom_stone_arrows", "abilities/heroes/medusa_custom_stone_arrows.lua", LUA_MODIFIER_MOTION_NONE)

modifier_medusa_custom_stone_arrows = class({})


function modifier_medusa_custom_stone_arrows:IsHidden()
    return true
end


function modifier_medusa_custom_stone_arrows:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end


function modifier_medusa_custom_stone_arrows:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("extra_damage")
end


function modifier_medusa_custom_stone_arrows:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("attack_speed_loss")
end


function modifier_medusa_custom_stone_arrows:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("move_speed_loss")
end
