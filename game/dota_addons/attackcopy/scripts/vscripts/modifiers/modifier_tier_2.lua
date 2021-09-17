LinkLuaModifier("modifier_skill_minitalon", "modifiers/modifier_tier_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_lightbones", "modifiers/modifier_tier_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_atronach", "modifiers/modifier_tier_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_overtuned", "modifiers/modifier_tier_2.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_intellect_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_all_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_skill_minitalon = class({})

function modifier_skill_minitalon:IsPurgable()
    return false
end

function modifier_skill_minitalon:IsHidden()
    return true
end

function modifier_skill_minitalon:IsDebuff()
    return false
end

function modifier_skill_minitalon:RemoveOnDeath()
    return false
end

function modifier_skill_minitalon:AllowIllusionDuplicate()
    return false
end

function modifier_skill_minitalon:GetTexture()
    return "modifier_skill_minitalon"
end
if IsServer() then
	function modifier_skill_minitalon:OnCreated()
		self.parent = self:GetParent()
		_G.AOHGameMode.SetTalon(self.parent:GetPlayerOwnerID(), 75, 0)
	end
	function modifier_skill_minitalon:OnDestroy()
		_G.AOHGameMode.SetTalon(self.parent:GetPlayerOwnerID(), -75, 0 )
	end
end

modifier_skill_lightbones = class({})

function modifier_skill_lightbones:IsPurgable()
    return false
end

function modifier_skill_lightbones:IsHidden()
    return true
end

function modifier_skill_lightbones:IsDebuff()
    return false
end

function modifier_skill_lightbones:RemoveOnDeath()
    return false
end

function modifier_skill_lightbones:AllowIllusionDuplicate()
    return true
end

function modifier_skill_lightbones:GetTexture()
    return "modifier_skill_lightbones"
end

function modifier_skill_lightbones:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }
end

function modifier_skill_lightbones:GetModifierExtraHealthPercentage()
    return -20
end

function modifier_skill_lightbones:GetModifierMoveSpeed_AbsoluteMin()
    return 350
end

function modifier_skill_lightbones:GetModifierPercentageCooldown()
    return 12
end

function modifier_skill_lightbones:GetModifierTurnRate_Percentage()
    return 50
end

modifier_skill_atronach = class({})

function modifier_skill_atronach:IsPurgable()
    return false
end

function modifier_skill_atronach:IsHidden()
    return true
end

function modifier_skill_atronach:IsDebuff()
    return false
end

function modifier_skill_atronach:RemoveOnDeath()
    return false
end

function modifier_skill_atronach:AllowIllusionDuplicate()
    return true
end

function modifier_skill_atronach:GetTexture()
    return "modifier_skill_atronach"
end

function modifier_skill_atronach:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE,
    }
end

function modifier_skill_atronach:GetTexture()
    return "modifier_skill_atronach"
end
function modifier_skill_atronach:OnCreated()
	self.parent = self:GetParent()
	if IsServer() then
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_token", {bonus = 12})
	end
end

function modifier_skill_atronach:OnDestroy()
	if IsServer() then
		self.modifier:Destroy()
	end
end

function modifier_skill_atronach:GetModifierExtraManaPercentage()
    return 50
end

function modifier_skill_atronach:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.075
    return -m_regen
end

modifier_skill_overtuned = class({})

function modifier_skill_overtuned:IsPurgable()
    return false
end

function modifier_skill_overtuned:IsHidden()
    return true
end

function modifier_skill_overtuned:IsDebuff()
    return false
end

function modifier_skill_overtuned:RemoveOnDeath()
    return false
end

function modifier_skill_overtuned:AllowIllusionDuplicate()
    return true
end

function modifier_skill_overtuned:GetTexture()
    return "modifier_skill_overtuned"
end

function modifier_skill_overtuned:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end

function modifier_skill_overtuned:GetModifierHealthRegenPercentage()
    return -1.5
end

function modifier_skill_overtuned:OnCreated()
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	if IsServer() then
		self.stat_modifier = self.parent:AddNewModifier(self.parent, ability, "modifier_bonus_all_token", {bonus = 15})
	end
end

function modifier_skill_overtuned:OnDestroy()
	if self.stat_modifier then
		self.stat_modifier:Destroy()
	end
end
