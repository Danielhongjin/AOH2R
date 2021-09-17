
item_aghanim_consumable = class({})


function item_aghanim_consumable:GetIntrinsicModifierName()
    return "modifier_item_aghanim_consumable"
end


LinkLuaModifier("modifier_item_aghanim_consumable", "items/item_aghanim_consumable.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_aghanim_consumable = class({})


function modifier_item_aghanim_consumable:IsHidden()
    return true
end

function modifier_item_aghanim_consumable:IsPurgable()
	return false
end

function modifier_item_aghanim_consumable:OnCreated()
	local parent = self:GetParent()
	if parent:IsRealHero() then
		parent:AddNewModifier(parent, nil, "modifier_item_aghanim_permanent", {duration = -1})
		self:GetAbility():Destroy()
		self:Destroy()
	end
end



LinkLuaModifier("modifier_item_aghanim_permanent", "items/item_aghanim_consumable.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_aghanim_permanent = class({})


function modifier_item_aghanim_permanent:IsHidden()
	return false
end

function modifier_item_aghanim_permanent:IsPurgable()
	return false
end

function modifier_item_aghanim_permanent:RemoveOnDeath()
	return false
end

function modifier_item_aghanim_permanent:AllowIllusionDuplicate()
	return true
end

function modifier_item_aghanim_permanent:GetTexture()
	return "item_ultimate_scepter"
end

function modifier_item_aghanim_permanent:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_IS_SCEPTER,
	}
	return funcs
end
function modifier_item_aghanim_permanent:GetModifierScepter()
	return 1
end
function modifier_item_aghanim_permanent:GetModifierBonusStats_Agility()
	return 15
end
function modifier_item_aghanim_permanent:GetModifierBonusStats_Strength()
	return 15
end
function modifier_item_aghanim_permanent:GetModifierBonusStats_Intellect()
	return 15
end
function modifier_item_aghanim_permanent:GetModifierHealthBonus()
	return 175
end
function modifier_item_aghanim_permanent:GetModifierManaBonus()
	return 175
end