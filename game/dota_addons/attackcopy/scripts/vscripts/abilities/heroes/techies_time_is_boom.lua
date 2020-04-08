
techies_time_is_boom = class({})


function techies_time_is_boom:GetIntrinsicModifierName()
    return "modifier_techies_time_is_boom"
end



LinkLuaModifier("modifier_techies_time_is_boom", "abilities/heroes/techies_time_is_boom.lua", LUA_MODIFIER_MOTION_NONE)

modifier_techies_time_is_boom = class({})


function modifier_techies_time_is_boom:IsHidden()
    return true
end
if IsServer() then

function modifier_techies_time_is_boom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end


function modifier_techies_time_is_boom:GetModifierPercentageCooldown()
    local ability = self:GetAbility()
    local base_cooldown_red = ability:GetSpecialValueFor("base_cooldown_red")
    local level_cooldown_red = ability:GetSpecialValueFor("level_cooldown_red")

    return base_cooldown_red + (level_cooldown_red * self:GetParent():GetLevel())
end
end
