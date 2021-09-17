modifier_bonus_strength_controller = class({})


function modifier_bonus_strength_controller:IsHidden()
    return true
end

function modifier_bonus_strength_controller:IsPurgable()
    return false
end

function modifier_bonus_strength_controller:RemoveOnDeath()
	return false
end

function modifier_bonus_strength_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_bonus_strength_controller:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end


if IsServer() then
	function modifier_bonus_strength_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.bonus = 0
	end

	function modifier_bonus_strength_controller:ModifyStacks(stacks)
		if self.bonus == 0 and (self.bonus + stacks) ~= 0 then
			self:StartIntervalThink(0.33)
		end
		self.bonus = self.bonus + stacks
	end
	
	function modifier_bonus_strength_controller:OnIntervalThink()
		if self.bonus == 0 then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
		end
		self:SetStackCount((self.parent:GetStrength() - self:GetStackCount()) * self.bonus * 0.01)
	end
end

modifier_bonus_agility_controller = class({})

function modifier_bonus_agility_controller:IsHidden()
    return true
end

function modifier_bonus_agility_controller:IsPurgable()
    return false
end

function modifier_bonus_agility_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS
	}
	return funcs
end

function modifier_bonus_agility_controller:RemoveOnDeath()
	return false
end

function modifier_bonus_agility_controller:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_bonus_agility_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.bonus = 0
	end

	function modifier_bonus_agility_controller:ModifyStacks(stacks)
		if self.bonus == 0 and (self.bonus + stacks) ~= 0 then
			self:StartIntervalThink(0.33)
		end
		self.bonus = self.bonus + stacks
	end
	
	function modifier_bonus_agility_controller:OnIntervalThink()
		if self.bonus == 0 then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
		end
		self:SetStackCount((self.parent:GetAgility() - self:GetStackCount()) * self.bonus * 0.01)
	end
end

modifier_bonus_intellect_controller = class({})

function modifier_bonus_intellect_controller:IsHidden()
    return true
end

function modifier_bonus_intellect_controller:IsPurgable()
    return false
end

function modifier_bonus_intellect_controller:RemoveOnDeath()
	return false
end

function modifier_bonus_intellect_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_bonus_intellect_controller:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end


if IsServer() then
	function modifier_bonus_intellect_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.bonus = 0
	end

	function modifier_bonus_intellect_controller:ModifyStacks(stacks)
		if self.bonus == 0 and (self.bonus + stacks) ~= 0 then
			self:StartIntervalThink(0.33)
		end
		self.bonus = self.bonus + stacks
	end
	
	function modifier_bonus_intellect_controller:OnIntervalThink()
		if self.bonus == 0 then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
		end
		self:SetStackCount((self.parent:GetIntellect() - self:GetStackCount()) * self.bonus * 0.01)
	end
end

modifier_bonus_attackspeed_controller = class({})


function modifier_bonus_attackspeed_controller:IsHidden()
    return true
end

function modifier_bonus_attackspeed_controller:IsPurgable()
    return false
end

function modifier_bonus_attackspeed_controller:RemoveOnDeath()
	return false
end

function modifier_bonus_attackspeed_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_bonus_attackspeed_controller:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_bonus_attackspeed_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.bonus = 0
	end

	function modifier_bonus_attackspeed_controller:ModifyStacks(stacks)
		if self.bonus == 0 and (self.bonus + stacks) ~= 0 then
			self:StartIntervalThink(0.33)
		end
		self.bonus = self.bonus + stacks
	end
	
	function modifier_bonus_attackspeed_controller:OnIntervalThink()
		if self.bonus == 0 then
			self:SetStackCount(0)
			self:StartIntervalThink(-1)
		end
		self:SetStackCount((self.parent:GetDisplayAttackSpeed() - self:GetStackCount()) * self.bonus * 0.01)
	end
end