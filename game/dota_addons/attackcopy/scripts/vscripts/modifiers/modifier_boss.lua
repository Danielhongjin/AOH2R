-- Takes care of all of the timing and skills for applicable abilities. Tickets are granted and incremented by abilties, it's up to
-- the abilities to make sure that tickets are properly released and checked. Lockouts are used by abilities to force lock the ability
-- queue.
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
		self.available_ticket = 0
		self.open_ticket = 0
		self.lockout = false
	end
	
	function modifier_boss:RequestTicket()
		local ticket = self.available_ticket
		self.available_ticket = self.available_ticket + 1
		return ticket
	end
	
	function modifier_boss:GetOpenTicket()
		return self.open_ticket
	end
	
	function modifier_boss:QueryTicket(key)
		if key == self.open_ticket and not self.lockout == true then
			return true
		else
			return false
		end
	end
	
	function modifier_boss:ReleaseTicket()
		self.open_ticket = self.open_ticket + 1
	end
	
	function modifier_boss:Lockout()
		self.lockout = true
	end
	function modifier_boss:ReleaseLockout()
		self.lockout = false
	end
	
	function modifier_boss:OnIntervalThink()
		self:IncrementStackCount()
	end

end
