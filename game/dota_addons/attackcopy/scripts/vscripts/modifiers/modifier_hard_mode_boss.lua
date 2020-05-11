
modifier_hard_mode_boss = class({})

function modifier_hard_mode_boss:IsBuff()
    return true
end

function modifier_hard_mode_boss:IsHidden()
    return false
end

function modifier_hard_mode_boss:GetTexture()
    return "custom_avatar_debuff"
end

function modifier_hard_mode_boss:IsPurgable()
    return false
end

function modifier_hard_mode_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
	return funcs
end

function modifier_hard_mode_boss:GetModifierPercentageCooldown()
    return 10
end

function modifier_hard_mode_boss:GetModifierTotalPercentageManaRegen()
	return 0.5
end
