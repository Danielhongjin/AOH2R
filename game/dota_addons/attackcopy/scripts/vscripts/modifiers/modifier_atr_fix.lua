require("lib/my")


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
	}
	return funcs
end


function modifier_atr_fix:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_atr_fix:GetModifierConstantHealthRegen()
	local parent_str = self.parent:GetStrength()
    local h_regen = parent_str * 0.1
    return h_regen
end

function modifier_atr_fix:OnCreated()
	self.parent = self:GetParent()
end

function modifier_atr_fix:GetModifierConstantManaRegen()
    local parent_int = self.parent:GetIntellect()
    local m_regen = parent_int * 0.0375
    return m_regen
end

function modifier_atr_fix:GetModifierSpellAmplify_Percentage()
	local parent_int = self.parent:GetIntellect()
    local amp = parent_int * 0.12
    return amp
end


