--[[Author: Pizzalol, Beaglepleaser9000
	Date: 30.12.2015.
	Takes ownership of the target unit]]
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
function Dominate( keys )

	local caster = keys.caster
	local target = keys.target
	if not target:IsConsideredHero() then
		local caster_team = caster:GetTeamNumber()
		local player = caster:GetPlayerOwnerID()
		local ability = keys.ability
		local movespeed = ability:GetSpecialValueFor("speed_base")
		local healthMin = ability:GetSpecialValueFor("health_min")
		if target:GetMaxHealth() < healthMin then
			target:SetBaseMaxHealth(healthMin)
		end
		target:SetBaseMoveSpeed(movespeed)
		ability.dominate_table = ability.dominate_table or {}
		local max_units = ability:GetSpecialValueFor("max_units")
		target:SetTeam(caster_team)
		target:SetOwner(caster)
		target:SetControllableByPlayer(player, true)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_custom_helm_of_the_dominator_buff", {duration = -1})
		FindClearSpaceForUnit( target, target:GetAbsOrigin(), true )
		target:AddNewModifier(target, nil, "modifier_summonbuff", {id = caster:GetPlayerID()})
		target:Stop()
		-- Track the unit
		table.insert(ability.dominate_table, target)

		-- If the maximum amount of units is reached then kill the oldest unit
		if #ability.dominate_table > max_units then
			ability.dominate_table[1]:ForceKill(true) 
		end
	end
end

--[[Author: Pizzalol
	Date: 06.04.2015.
	Removes the target from the table]]
function DominateRemove( keys )
	local target = keys.target
	local ability = keys.ability

	-- Find the unit and remove it from the table
	for i = 1, #ability.dominate_table do
		if ability.dominate_table[i] == target then
			table.remove(ability.dominate_table, i)
			break
		end
	end
end

function AddBuff(keys)
	local target = keys.target
	local ability = keys.ability
	if not target:IsConsideredHero() then
		target:AddNewModifier(target, ability, "modifier_helm_creep_bonus", {})	
	else
		target:AddNewModifier(target, ability, "modifier_helm_hero_bonus", {})	
	end
end

function RemoveBuff(keys)
	local target = keys.target
	local ability = keys.ability
	if not target:IsConsideredHero() then
		target:RemoveModifierByName("modifier_helm_creep_bonus")
	else
		target:RemoveModifierByName("modifier_helm_hero_bonus")
	end
end

LinkLuaModifier("modifier_helm_hero_bonus", "items/custom_helm_of_the_dominator.lua", LUA_MODIFIER_MOTION_NONE)
modifier_helm_hero_bonus = class({})

function modifier_helm_hero_bonus:IsPurgable()
	return false
end

function modifier_helm_hero_bonus:RemoveOnDeath()
	return false
end

function modifier_helm_hero_bonus:IsHidden()
	return false
end

function modifier_helm_hero_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }
end


function modifier_helm_hero_bonus:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen_aura")
end

function modifier_helm_hero_bonus:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("attack_damage_aura")
end

LinkLuaModifier("modifier_helm_creep_bonus", "items/custom_helm_of_the_dominator.lua", LUA_MODIFIER_MOTION_NONE)
modifier_helm_creep_bonus = class({})

function modifier_helm_creep_bonus:IsPurgable()
	return false
end

function modifier_helm_creep_bonus:RemoveOnDeath()
	return false
end

function modifier_helm_creep_bonus:IsHidden()
	return false
end

function modifier_helm_creep_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }
end


function modifier_helm_creep_bonus:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen_aura") * (1 + self:GetAbility():GetSpecialValueFor("creep_bonus") * 0.01)
end

function modifier_helm_creep_bonus:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("attack_damage_aura") * (1 + self:GetAbility():GetSpecialValueFor("creep_bonus") * 0.01)
end
