


modifier_bonus_primary_controller = class({})


function modifier_bonus_primary_controller:IsHidden()
    return true
end


function modifier_bonus_primary_controller:IsPurgable()
    return false
end

function modifier_bonus_primary_controller:RemoveOnDeath()
	return false
end

function modifier_bonus_primary_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_bonus_primary_controller:GetModifierBonusStats_Agility()
	return self.agi
end
function modifier_bonus_primary_controller:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_bonus_primary_controller:GetModifierBonusStats_Intellect()
	return self.int
end
function modifier_bonus_primary_controller:OnCreated(keys)
	self.parent = self:GetParent()
	self.agi = 0
	self.int = 0
	self.str = 0
	self:StartIntervalThink(0.25)
end

if IsServer() then
	function modifier_bonus_primary_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		attribute = self.parent:GetPrimaryAttribute()
		if attribute == 0 then
			self.str = (self.parent:GetStrength() - self.str) * self:GetStackCount() * 0.01
			self.agi = 0
			self.int = 0
		elseif attribute == 1 then
			self.agi = (self.parent:GetAgility() - self.agi) * self:GetStackCount() * 0.01
			self.str = 0
			self.int = 0
		else
			self.int = (self.parent:GetIntellect() - self.int) * self:GetStackCount() * 0.01
			self.agi = 0
			self.str = 0
		end
		self.parent:CalculateStatBonus()
	end
end

modifier_bonus_primary_token = class({})


function modifier_bonus_primary_token:IsHidden()
    return true
end

function modifier_bonus_primary_token:IsPurgable()
    return false
end

function modifier_bonus_primary_token:RemoveOnDeath()
	return false
end

function modifier_bonus_primary_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_primary_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_bonus_primary_controller")
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_primary_token:OnDestroy()
		self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
	end
end
--[[
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

function modifier_bonus_agility_controller:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_bonus_agility_controller:OnCreated(keys)
	self.parent = self:GetParent()
	self.agi = 0
	self:StartIntervalThink(0.5)
end

if IsServer() then
	function modifier_bonus_agility_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		self.agi = (self.parent:GetAgility() - self.agi) * self:GetStackCount() * 0.01
	end
end

modifier_bonus_agility_token = class({})


function modifier_bonus_agility_token:IsHidden()
    return true
end

function modifier_bonus_agility_token:IsPurgable()
    return false
end

function modifier_bonus_agility_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_agility_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_bonus_agility_controller")
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_agility_token:OnDestroy()
		self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
	end
end


modifier_bonus_strength_controller = class({})


function modifier_bonus_strength_controller:IsHidden()
    return true
end


function modifier_bonus_strength_controller:IsPurgable()
    return false
end

function modifier_bonus_strength_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_bonus_strength_controller:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_bonus_strength_controller:OnCreated(keys)
	self.parent = self:GetParent()
	self.str = 0
	self:StartIntervalThink(0.5)
end

if IsServer() then
	function modifier_bonus_strength_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		self.str = (self.parent:GetStrength() - self.str) * self:GetStackCount() * 0.01
	end
end

modifier_bonus_strength_token = class({})


function modifier_bonus_strength_token:IsHidden()
    return true
end

function modifier_bonus_strength_token:IsPurgable()
    return false
end

function modifier_bonus_strength_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_strength_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_bonus_strength_controller")
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_strength_token:OnDestroy()
		self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
	end
end

modifier_bonus_intellect_controller = class({})


function modifier_bonus_intellect_controller:IsHidden()
    return true
end


function modifier_bonus_intellect_controller:IsPurgable()
    return false
end

function modifier_bonus_intellect_controller:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
	return funcs
end

function modifier_bonus_intellect_controller:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_bonus_intellect_controller:OnCreated(keys)
	self.parent = self:GetParent()
	self.int = 0
	self:StartIntervalThink(0.5)
end

if IsServer() then
	function modifier_bonus_intellect_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		self.int = (self.parent:GetIntellect() - self.int) * self:GetStackCount() * 0.01
	end
end

modifier_bonus_intellect_token = class({})


function modifier_bonus_intellect_token:IsHidden()
    return true
end

function modifier_bonus_intellect_token:IsPurgable()
    return false
end

function modifier_bonus_intellect_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_intellect_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_bonus_intellect_controller")
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_intellect_token:OnDestroy()
		self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
	end
end
]]--