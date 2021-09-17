LinkLuaModifier("modifier_bonus_primary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)

modifier_hard_mode_player = class({})

function modifier_hard_mode_player:IsPurgable()
    return false
end

function modifier_hard_mode_player:IsDebuff()
    return false
end

function modifier_hard_mode_player:RemoveOnDeath()
    return false
end

function modifier_hard_mode_player:AllowIllusionDuplicate()
    return true
end

function modifier_hard_mode_player:GetTexture()
    return "blessings"
end
if IsServer() then
	function modifier_hard_mode_player:OnCreated()
		local parent = self:GetParent()
		parent:AddNewModifier(parent, nil, "modifier_bonus_primary_token", {bonus = 12})
	end
end