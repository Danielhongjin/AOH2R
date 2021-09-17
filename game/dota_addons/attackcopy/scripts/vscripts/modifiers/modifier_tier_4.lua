
LinkLuaModifier("modifier_skill_noevil", "modifiers/modifier_tier_4.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_jack", "modifiers/modifier_tier_4.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_cardio", "modifiers/modifier_tier_4.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_bloodmana", "modifiers/modifier_tier_4.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/data")
modifier_skill_noevil = class({})

function modifier_skill_noevil:IsPurgable()
    return false
end

function modifier_skill_noevil:IsDebuff()
    return false
end

function modifier_skill_noevil:RemoveOnDeath()
    return false
end

function modifier_skill_noevil:AllowIllusionDuplicate()
    return false
end

function modifier_skill_noevil:GetTexture()
    return "modifier_skill_noevil"
end

function modifier_skill_noevil:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_skill_noevil:GetModifierTotalDamageOutgoing_Percentage()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_skill_noevil:OnCreated()
		self.parent = self:GetParent()
		self.playerID = self.parent:GetPlayerOwnerID()
		local player_damage = player_data_get_value(self.playerID, "bossDamage")
		local total = 1
		for i= 0, 4 do
			total = total + player_data_get_value(i, "bossDamage")
		end
		self:SetStackCount(math.floor((1 - (player_damage / total)) * 40))
		self:StartIntervalThink(2)
	end
	function modifier_skill_noevil:OnIntervalThink()
		local player_damage = player_data_get_value(self.playerID, "bossDamage")
		local total = 1
		for i= 0, 4 do
			total = total + player_data_get_value(i, "bossDamage")
		end
		self:SetStackCount(math.floor(((1 - (player_damage / total)) * 40)))
	end
	function modifier_skill_noevil:OnDestroy()
		
	end
end

modifier_skill_jack = class({})

function modifier_skill_jack:IsPurgable()
    return false
end

function modifier_skill_jack:IsDebuff()
    return false
end

function modifier_skill_jack:RemoveOnDeath()
    return false
end

function modifier_skill_jack:AllowIllusionDuplicate()
    return true
end

function modifier_skill_jack:GetTexture()
    return "modifier_skill_jack"
end

function modifier_skill_jack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
	return funcs
end

function modifier_skill_jack:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount()
end

if IsServer() then
	function modifier_skill_jack:OnCreated()
		local parent = self:GetParent()
		local attribute = parent:GetPrimaryAttribute()
		local total = 0
		if attribute == 0 then
			total = parent:GetIntellect() + parent:GetAgility()
		elseif attribute == 1 then
			total = parent:GetStrength() + parent:GetIntellect()
		else
			total = parent:GetStrength() + parent:GetAgility() 
		end
		self:SetStackCount(total * 0.5)
		self:StartIntervalThink(0.33)
	end
	function modifier_skill_jack:OnIntervalThink()
		local parent = self:GetParent()
		local attribute = parent:GetPrimaryAttribute()
		local total = 0
		if attribute == 0 then
			total = parent:GetIntellect() + parent:GetAgility()
		elseif attribute == 1 then
			total = parent:GetStrength() + parent:GetIntellect()
		else
			total = parent:GetStrength() + parent:GetAgility()
		end
		self:SetStackCount(total * 0.5)

	end
end

modifier_skill_cardio = class({})

function modifier_skill_cardio:IsPurgable()
    return false
end

function modifier_skill_cardio:IsHidden()
    return true
end

function modifier_skill_cardio:IsDebuff()
    return false
end

function modifier_skill_cardio:RemoveOnDeath()
    return false
end

function modifier_skill_cardio:AllowIllusionDuplicate()
    return false
end

function modifier_skill_cardio:GetTexture()
    return "modifier_skill_cardio"
end
if IsServer() then
	function modifier_skill_cardio:OnCreated()
		local parent = self:GetParent()
		self.fx = ParticleManager:CreateParticleForPlayer("particles/custom/marathon_circle.vpcf", PATTACH_ABSORIGIN, parent, parent:GetPlayerOwner())
		ParticleManager:SetParticleControlEnt(self.fx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", parent:GetAbsOrigin(), true)
	end
	function modifier_skill_cardio:OnDestroy()
		
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end
modifier_skill_bloodmana = class({})

function modifier_skill_bloodmana:IsPurgable()
    return false
end

function modifier_skill_bloodmana:IsHidden()
    return true
end

function modifier_skill_bloodmana:IsDebuff()
    return false
end

function modifier_skill_bloodmana:RemoveOnDeath()
    return false
end

function modifier_skill_bloodmana:AllowIllusionDuplicate()
    return true
end

function modifier_skill_bloodmana:GetTexture()
    return "modifier_skill_bloodmana"
end

function modifier_skill_bloodmana:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_SPELLS_REQUIRE_HP,
    }
end

function modifier_skill_bloodmana:GetModifierSpellsRequireHP()
	return 1
end
