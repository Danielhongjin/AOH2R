LinkLuaModifier("modifier_bonus_strength_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_agility_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_intellect_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_attackspeed_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_primary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_secondary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)

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

if IsServer() then
	function modifier_bonus_primary_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.strength_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_strength_controller", {})
		self.agility_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_agility_controller", {})
		self.intellect_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_controller", {})
		self.current_attribute = self.parent:GetPrimaryAttribute()
		self.current_stacks = self:GetStackCount()
		if self.current_attribute == 0 then
			self.strength_modifier:ModifyStacks(self:GetStackCount())
		elseif self.current_attribute == 1 then
			self.agility_modifier:ModifyStacks(self:GetStackCount())
		else
			self.intellect_modifier:ModifyStacks(self:GetStackCount())
		end
		self:StartIntervalThink(0.25)
	end

	function modifier_bonus_primary_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		local attribute = self.parent:GetPrimaryAttribute()
		if attribute ~= self.current_attribute then
			if self.current_attribute == 0 then
				self.strength_modifier:ModifyStacks(-self:GetStackCount())
			elseif self.current_attribute == 1 then
				self.agility_modifier:ModifyStacks(-self:GetStackCount())
			else
				self.intellect_modifier:ModifyStacks(-self:GetStackCount())
			end
			if attribute == 0 then
				self.strength_modifier:ModifyStacks(self:GetStackCount())
			elseif attribute == 1 then
				self.agility_modifier:ModifyStacks(self:GetStackCount())
			else
				self.intellect_modifier:ModifyStacks(self:GetStackCount())
			end
			self.current_attribute = attribute
		end
		local count = self:GetStackCount()
		if self.current_stacks ~= count then
			if self.current_attribute == 0 then
				self.strength_modifier:ModifyStacks(-self.current_stacks)
				self.strength_modifier:ModifyStacks(count)
			elseif self.current_attribute == 1 then
				self.agility_modifier:ModifyStacks(-self.current_stacks)
				self.agility_modifier:ModifyStacks(count)
			else
				self.intellect_modifier:ModifyStacks(-self.current_stacks)
				self.intellect_modifier:ModifyStacks(count)
			end
			self.current_stacks = count
		end
		self.parent:CalculateStatBonus(true)
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
		self.bonus = keys.bonus
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_primary_controller", {})
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_primary_token:OnDestroy()
		if self.modifier then
			self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
		end
	end
end


modifier_bonus_secondary_controller = class({})

function modifier_bonus_secondary_controller:IsHidden()
    return true
end

function modifier_bonus_secondary_controller:IsPurgable()
    return false
end

function modifier_bonus_secondary_controller:RemoveOnDeath()
	return false
end


if IsServer() then
	function modifier_bonus_secondary_controller:OnCreated(keys)
		self.parent = self:GetParent()
		self.strength_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_strength_controller", {})
		self.agility_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_agility_controller", {})
		self.intellect_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_controller", {})
		self.current_attribute = self.parent:GetPrimaryAttribute()
		self.current_stacks = self:GetStackCount()
		if self.current_attribute == 0 then
			self.agility_modifier:ModifyStacks(self:GetStackCount())
			self.intellect_modifier:ModifyStacks(self:GetStackCount())
		elseif self.current_attribute == 1 then
			self.strength_modifier:ModifyStacks(self:GetStackCount())
			self.intellect_modifier:ModifyStacks(self:GetStackCount())
		else
			self.agility_modifier:ModifyStacks(self:GetStackCount())
			self.strength_modifier:ModifyStacks(self:GetStackCount())
		end
		self:StartIntervalThink(0.25)
	end
	function modifier_bonus_secondary_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self:Destroy()
		end
		local attribute = self.parent:GetPrimaryAttribute()
		if attribute ~= self.current_attribute then
			if self.current_attribute == 0 then
				self.agility_modifier:ModifyStacks(-self:GetStackCount())
				self.intellect_modifier:ModifyStacks(-self:GetStackCount())
			elseif self.current_attribute == 1 then
				self.strength_modifier:ModifyStacks(-self:GetStackCount())
				self.intellect_modifier:ModifyStacks(-self:GetStackCount())
			else
				self.agility_modifier:ModifyStacks(-self:GetStackCount())
				self.strength_modifier:ModifyStacks(-self:GetStackCount())
			end
			if attribute == 0 then
				self.agility_modifier:ModifyStacks(self:GetStackCount())
				self.intellect_modifier:ModifyStacks(self:GetStackCount())
			elseif attribute == 1 then
				self.strength_modifier:ModifyStacks(self:GetStackCount())
				self.intellect_modifier:ModifyStacks(self:GetStackCount())
			else
				self.strength_modifier:ModifyStacks(self:GetStackCount())
				self.agility_modifier:ModifyStacks(self:GetStackCount())
			end
			self.current_attribute = attribute
		end
		local count = self:GetStackCount()
		if self.current_stacks ~= count then
			if self.current_attribute == 0 then
				self.agility_modifier:ModifyStacks(-self.current_stacks)
				self.agility_modifier:ModifyStacks(count)
				self.intellect_modifier:ModifyStacks(-self.current_stacks)
				self.intellect_modifier:ModifyStacks(count)
			elseif self.current_attribute == 1 then
				self.strength_modifier:ModifyStacks(-self.current_stacks)
				self.strength_modifier:ModifyStacks(count)
				self.intellect_modifier:ModifyStacks(-self.current_stacks)
				self.intellect_modifier:ModifyStacks(count)
			else
				self.strength_modifier:ModifyStacks(-self.current_stacks)
				self.strength_modifier:ModifyStacks(count)
				self.agility_modifier:ModifyStacks(-self.current_stacks)
				self.agility_modifier:ModifyStacks(count)
			end
			self.current_stacks = count
		end
		self.parent:CalculateStatBonus(true)
	end
end

modifier_bonus_secondary_token = class({})


function modifier_bonus_secondary_token:IsHidden()
    return true
end

function modifier_bonus_secondary_token:IsPurgable()
    return false
end

function modifier_bonus_secondary_token:RemoveOnDeath()
	return false
end

function modifier_bonus_secondary_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_secondary_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_secondary_controller", {})
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
	end
	function modifier_bonus_secondary_token:OnDestroy()
		if self.modifier then
			self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
		end
	end
end


modifier_bonus_all_token = class({})

function modifier_bonus_all_token:IsHidden()
    return true
end

function modifier_bonus_all_token:IsPurgable()
    return false
end

function modifier_bonus_all_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_bonus_all_token:RemoveOnDeath()
	return false
end

if IsServer() then
	function modifier_bonus_all_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.strength_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_strength_controller", {})
		self.agility_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_agility_controller", {})
		self.intellect_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_controller", {})
		self.bonus = keys.bonus
		self.strength_modifier:ModifyStacks(self.bonus)
		self.agility_modifier:ModifyStacks(self.bonus)
		self.intellect_modifier:ModifyStacks(self.bonus)
	end
	function modifier_bonus_all_token:OnDestroy()
		if self.strength_modifier then
			self.strength_modifier:ModifyStacks(-self.bonus)
		end
		if self.agility_modifier then
			self.agility_modifier:ModifyStacks(-self.bonus)
		end
		if self.intellect_modifier then
			self.intellect_modifier:ModifyStacks(-self.bonus)
		end
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
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_agility_controller", {})
		self.bonus = keys.bonus
		self.modifier:ModifyStacks(self.bonus)
	end
	function modifier_bonus_agility_token:OnDestroy()
		if self.modifier then
			self.modifier:ModifyStacks(-self.bonus)
		end
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
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_strength_controller", {})
		self.bonus = keys.bonus
		self.modifier:ModifyStacks(self.bonus)
	end
	function modifier_bonus_strength_token:OnDestroy()
		if self.modifier then
			self.modifier:ModifyStacks(-self.bonus)
		end
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
		self.modifier = nil
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_controller", {})
		self.bonus = keys.bonus
		self.modifier:ModifyStacks(self.bonus)
	end
	function modifier_bonus_intellect_token:OnDestroy()
		self.modifier:ModifyStacks(-self.bonus)
	end
end

modifier_bonus_attackspeed_token = class({})

function modifier_bonus_attackspeed_token:IsHidden()
    return true
end

function modifier_bonus_attackspeed_token:IsPurgable()
    return false
end

function modifier_bonus_attackspeed_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_bonus_attackspeed_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = nil
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_attackspeed_controller", {})
		self.bonus = keys.bonus
		self.modifier:ModifyStacks(self.bonus)
	end
	function modifier_bonus_attackspeed_token:OnDestroy()
		if self.modifier then
			self.modifier:ModifyStacks(-self.bonus)
		end
	end
end