function aura_initiate(keys)
	local caster = keys.caster
	local parent = keys.target
	if caster:GetPlayerOwnerID() == parent:GetPlayerOwnerID() and parent:IsClone() then
		parent:AddNewModifier(caster, keys.ability, "modifier_meepo_custom_clone_buff", {})
	end
end



LinkLuaModifier("modifier_meepo_custom_clone_buff", "abilities/heroes/meepo_custom_clone_buff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_meepo_custom_clone_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_meepo_custom_clone_buff:IsDebuff()
	return true
end

function modifier_meepo_custom_clone_buff:IsHidden()
	return true
end

function modifier_meepo_custom_clone_buff:IsPurgable()
	return false
end



--------------------------------------------------------------------------------
-- Declare Functions
function modifier_meepo_custom_clone_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end



function modifier_meepo_custom_clone_buff:OnCreated()
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local parent = self:GetParent()
	meepo_copy_items(caster, parent)
	
end
