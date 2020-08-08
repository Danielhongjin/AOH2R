LinkLuaModifier("modifier_atr_fix", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
hero_attribute_fix = class({})


function hero_attribute_fix:GetIntrinsicModifierName()
    return "modifier_atr_fix"
end
if IsServer() then

	function hero_attribute_fix:OnHeroLevelUp()
		self:GetCaster():FindModifierByName("modifier_atr_fix"):ForceRefresh()
	end
end


modifier_atr_fix = class({})


function modifier_atr_fix:IsHidden()
    return true
end
function modifier_atr_fix:RemoveOnDeath()
    return false
end

function modifier_atr_fix:IsPurgable()
    return false
end

function modifier_atr_fix:GetTexture()
    return "atr_fix"
end


function modifier_atr_fix:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
	}
	return funcs
end


function modifier_atr_fix:GetModifierConstantHealthRegen()
	local parent_str = self.parent:GetStrength()
    local h_regen = parent_str * 0.1
    return h_regen
end

function modifier_atr_fix:OnCreated()
	self.parent = self:GetParent()
	self.level = self:GetParent()
	if self.parent:IsIllusion() then
		self.level = PlayerResource:GetSelectedHeroEntity(self.parent:GetPlayerOwnerID())
	end
end

function modifier_atr_fix:OnRefresh()
	self:SetStackCount(self.level:GetLevel() * 25)
end


function modifier_atr_fix:GetModifierHealthBonus()
    return self:GetStackCount()
end

function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.05
    return m_regen
end

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
	local parent_int = self.parent:GetIntellect()
    local amp = parent_int * 0.12
    return amp
end


