

lich_custom_cold_soul = class({})


function lich_custom_cold_soul:GetIntrinsicModifierName()
    return "modifier_lich_custom_cold_soul"
end


function lich_custom_cold_soul:IsStealable()
    return false
end



LinkLuaModifier("modifier_lich_custom_cold_soul", "abilities/heroes/lich_custom_cold_soul.lua", LUA_MODIFIER_MOTION_NONE)

modifier_lich_custom_cold_soul = class({})


function modifier_lich_custom_cold_soul:IsHidden()
    return true
end


function modifier_lich_custom_cold_soul:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
end


function modifier_lich_custom_cold_soul:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("spell_amp")
end

