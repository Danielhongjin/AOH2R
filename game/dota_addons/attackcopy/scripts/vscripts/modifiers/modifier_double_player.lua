LinkLuaModifier("modifier_bonus_secondary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
modifier_double_player = class({})

function modifier_double_player:IsPurgable()
    return false
end

function modifier_double_player:IsDebuff()
    return false
end

function modifier_double_player:RemoveOnDeath()
    return false
end

function modifier_double_player:AllowIllusionDuplicate()
    return true
end

function modifier_double_player:GetTexture()
    return "phantom_lancer_juxtapose"
end
if IsServer() then
	function modifier_double_player:OnCreated()
		local parent = self:GetParent()
		parent:AddNewModifier(parent, nil, "modifier_bonus_secondary_token", {bonus = 12})
	end
end