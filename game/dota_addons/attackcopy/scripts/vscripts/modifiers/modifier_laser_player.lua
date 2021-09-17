
modifier_laser_player = class({})

function modifier_laser_player:IsPurgable()
    return false
end

function modifier_laser_player:IsDebuff()
    return false
end

function modifier_laser_player:RemoveOnDeath()
    return false
end

function modifier_laser_player:AllowIllusionDuplicate()
    return true
end

function modifier_laser_player:GetTexture()
    return "lina_light_strike_array"
end

function modifier_laser_player:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_laser_player:GetModifierMoveSpeedBonus_Percentage()
    return 10
end

function modifier_laser_player:GetModifierAttackSpeedBonus_Constant()
    return 20
end