
LinkLuaModifier("modifier_skill_dashcooldown", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_equalizer", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_equalizer_health", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_equalizer_mana", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_dashimmunity", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_flashcaster", "modifiers/modifier_tier_1.lua", LUA_MODIFIER_MOTION_NONE)
modifier_skill_dashcooldown = class({})

function modifier_skill_dashcooldown:IsPurgable()
    return false
end

function modifier_skill_dashcooldown:IsHidden()
    return true
end

function modifier_skill_dashcooldown:IsDebuff()
    return false
end

function modifier_skill_dashcooldown:RemoveOnDeath()
    return false
end

function modifier_skill_dashcooldown:GetTexture()
    return "modifier_skill_dashcooldown"
end


modifier_skill_equalizer = class({})

function modifier_skill_equalizer:IsPurgable()
    return false
end

function modifier_skill_equalizer:IsHidden()
    return true
end

function modifier_skill_equalizer:IsDebuff()
    return false
end

function modifier_skill_equalizer:RemoveOnDeath()
    return false
end

function modifier_skill_equalizer:GetTexture()
    return "modifier_skill_equalizer"
end
if IsServer() then
	function modifier_skill_equalizer:OnCreated()
		self.parent = self:GetParent()
		self.health_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_skill_equalizer_health", {duration = -1})
		self.mana_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_skill_equalizer_mana", {duration = -1})
		self:StartIntervalThink(0.25)
	end
	function modifier_skill_equalizer:OnDestroy()
		self.health_modifier:Destroy()
		self.mana_modifier:Destroy()
	end
end

function modifier_skill_equalizer:OnIntervalThink()
	local mana_health_difference = self.parent:GetHealthPercent() - self.parent:GetManaPercent()
	if math.abs(mana_health_difference) > 5 then
		if mana_health_difference > 0 then
			local diff = self.parent:GetStrength() * 0.25 * 0.66
			self.health_modifier:SetStackCount(-diff)
			self.mana_modifier:SetStackCount(diff)
		else
			local diff = self.parent:GetIntellect()* 0.1 * 0.66
			self.health_modifier:SetStackCount(diff * 1.5)
			self.mana_modifier:SetStackCount(-diff)
		end
	else
		self.health_modifier:SetStackCount(0)
		self.mana_modifier:SetStackCount(0)
	end
end

modifier_skill_equalizer_health = class({})

function modifier_skill_equalizer_health:IsPurgable()
    return false
end

function modifier_skill_equalizer_health:IsDebuff()
    return false
end

function modifier_skill_equalizer_health:IsHidden()
    return true
end


function modifier_skill_equalizer_health:RemoveOnDeath()
    return false
end

function modifier_skill_equalizer_health:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_skill_equalizer_health:GetModifierConstantHealthRegen()
	return self:GetStackCount()
end


modifier_skill_equalizer_mana = class({})

function modifier_skill_equalizer_mana:IsPurgable()
    return false
end

function modifier_skill_equalizer_mana:IsDebuff()
    return false
end

function modifier_skill_equalizer_mana:IsHidden()
    return true
end


function modifier_skill_equalizer_mana:RemoveOnDeath()
    return false
end

function modifier_skill_equalizer_mana:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_skill_equalizer_mana:GetModifierConstantManaRegen()
	return self:GetStackCount()
end

modifier_skill_dashimmunity = class({})

function modifier_skill_dashimmunity:IsPurgable()
    return false
end

function modifier_skill_dashimmunity:IsHidden()
    return true
end

function modifier_skill_dashimmunity:IsDebuff()
    return false
end

function modifier_skill_dashimmunity:RemoveOnDeath()
    return false
end

function modifier_skill_dashimmunity:GetTexture()
    return "modifier_skill_dashimmunity"
end



modifier_skill_flashcaster = class({})

function modifier_skill_flashcaster:IsPurgable()
    return false
end

function modifier_skill_flashcaster:IsHidden()
    return true
end

function modifier_skill_flashcaster:IsDebuff()
    return false
end

function modifier_skill_flashcaster:RemoveOnDeath()
    return false
end

function modifier_skill_flashcaster:AllowIllusionDuplicate()
    return true
end

function modifier_skill_flashcaster:GetTexture()
    return "modifier_skill_flashcaster"
end

function modifier_skill_flashcaster:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end

function modifier_skill_flashcaster:GetModifierPercentageCasttime()
    return 66
end

function modifier_skill_flashcaster:GetModifierConstantManaRegen()
    return 3
end
