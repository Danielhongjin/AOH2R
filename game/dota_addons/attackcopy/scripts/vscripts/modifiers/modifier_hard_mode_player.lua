

modifier_hard_mode_player = class({})

function modifier_hard_mode_player:IsPurgable()
    return false
end

function modifier_hard_mode_player:IsDebuff()
    return false
end

function modifier_hard_mode_player:RemoveOnDeath()
    return false
end

function modifier_hard_mode_player:GetTexture()
    return "blessings"
end
