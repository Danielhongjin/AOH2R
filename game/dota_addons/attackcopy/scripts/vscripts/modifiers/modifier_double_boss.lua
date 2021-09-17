
modifier_double_boss = class({})

function modifier_double_boss:IsBuff()
    return true
end

function modifier_double_boss:IsHidden()
    return false
end

function modifier_double_boss:GetTexture()
    return "phantom_lancer_juxtapose"
end

function modifier_double_boss:IsPurgable()
    return false
end

function modifier_double_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
	return funcs
end

function modifier_double_boss:GetModifierExtraHealthPercentage()
    return -25
end

function modifier_double_boss:GetModifierPercentageCooldown()
    return -15
end