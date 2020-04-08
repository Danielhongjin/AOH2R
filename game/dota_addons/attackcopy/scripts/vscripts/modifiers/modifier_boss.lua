
modifier_boss = class({})

function modifier_boss:IsBuff()
    return true
end
function modifier_boss:IsHidden()
    return false
end

function modifier_boss:GetTexture()
    return "earth_spirit_rolling_boulder"
end

function modifier_boss:IsPurgable()
    return false
end

function modifier_boss:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end


function modifier_boss:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount()
end
function modifier_boss:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * 0.33
end

if IsServer() then
	function modifier_boss:OnCreated()
		self:StartIntervalThink(2.25)
		self.parent = self:GetParent()
	end

	function modifier_boss:OnIntervalThink()
		self:IncrementStackCount()
	end

end
