
modifier_easy_mode_boss = class({})

function modifier_easy_mode_boss:IsBuff()
    return false
end

function modifier_easy_mode_boss:IsHidden()
    return false
end

function modifier_easy_mode_boss:GetTexture()
    return "omniknight_repel"
end

function modifier_easy_mode_boss:IsPurgable()
    return false
end

function modifier_easy_mode_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_easy_mode_boss:GetModifierPercentageCooldown()
    return -30
end

function modifier_easy_mode_boss:GetModifierTotalDamageOutgoing_Percentage()
	return -20
end
