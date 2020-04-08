function aura_initiate(keys)
	local caster = keys.caster
	local parent = keys.target
	if caster:GetPlayerOwnerID() == parent:GetPlayerOwnerID() and parent:GetUnitName() == "npc_dota_clinkz_skeleton_archer_frostivus2018"  then
		if caster:GetPlayerOwner() == parent:GetPlayerOwner() and not parent:HasModifier("modifier_pharaoh_crown_buff") and parent:GetUnitLabel() ~= "ancient" then
			parent:AddNewModifier(caster, keys.ability, "modifier_clinkz_custom_ward_buff", {})
		end
	end
end

function LevelUpWardBuff (keys)
	local caster = keys.caster
	local ability_ward_buff = caster:AddAbility("clinkz_custom_ward_buff")
	ability_ward_buff:SetLevel(1)
end

LinkLuaModifier("modifier_clinkz_custom_ward_buff", "abilities/heroes/clinkz_custom_ward_buff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_ward_buff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_clinkz_custom_ward_buff:IsDebuff()
	return true
end

function modifier_clinkz_custom_ward_buff:IsHidden()
	return true
end

function modifier_clinkz_custom_ward_buff:IsPurgable()
	return false
end



--------------------------------------------------------------------------------
-- Declare Functions
function modifier_clinkz_custom_ward_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

function modifier_clinkz_custom_ward_buff:GetModifierAttackRangeBonus()
	local caster = self:GetCaster()
	return caster:Script_GetAttackRange() - 500
end




