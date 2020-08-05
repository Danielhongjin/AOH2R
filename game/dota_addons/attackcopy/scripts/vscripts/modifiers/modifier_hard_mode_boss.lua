
modifier_hard_mode_boss = class({})

function modifier_hard_mode_boss:IsBuff()
    return true
end

function modifier_hard_mode_boss:IsHidden()
    return false
end

function modifier_hard_mode_boss:GetTexture()
    return "hard_mode"
end

function modifier_hard_mode_boss:IsPurgable()
    return false
end

function modifier_hard_mode_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
	return funcs
end

function modifier_hard_mode_boss:GetModifierPercentageCooldown()
    return 20
end

function modifier_hard_mode_boss:GetModifierTotalPercentageManaRegen()
	return 0.5
end

function modifier_hard_mode_boss:GetModifierHealthRegenPercentage()
	return 0.65
end