
modifier_sudden_death_player = class({})

function modifier_sudden_death_player:IsBuff()
    return true
end

function modifier_sudden_death_player:IsHidden()
    return false
end

function modifier_sudden_death_player:GetTexture()
    return "baby_mode"
end

function modifier_sudden_death_player:IsPurgable()
    return false
end

function modifier_sudden_death_player:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_sudden_death_player:GetModifierExtraHealthPercentage()
    return -40
end

function modifier_sudden_death_player:GetModifierStatusResistance()
    return 66
end

function modifier_sudden_death_player:GetModifierBonusStats_Agility()
    return 10
end

function modifier_sudden_death_player:GetModifierBonusStats_Intellect()
    return 10
end

function modifier_sudden_death_player:GetModifierBonusStats_Strength()
    return 10
end