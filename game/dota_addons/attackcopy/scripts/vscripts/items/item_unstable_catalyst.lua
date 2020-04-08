item_unstable_catalyst = class({})

function item_unstable_catalyst:OnSpellStart()
	end
	
function item_unstable_catalyst:GetIntrinsicModifierName()
	return "modifier_item_unstable_catalyst"
end


LinkLuaModifier("modifier_item_unstable_catalyst", "items/item_unstable_catalyst.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_unstable_catalyst = class({})

function modifier_item_unstable_catalyst:IsHidden()
	return true
end

function modifier_item_unstable_catalyst:IsPurgable()
	return false
end
function modifier_item_unstable_catalyst:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELLS_REQUIRE_HP,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
	}
end

function modifier_item_unstable_catalyst:IsPurgable()
	return false
end