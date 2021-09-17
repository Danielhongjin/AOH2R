
modifier_nightmare_player = class({})

function modifier_nightmare_player:IsPurgable()
    return false
end

function modifier_nightmare_player:IsDebuff()
    return false
end

function modifier_nightmare_player:RemoveOnDeath()
    return false
end

function modifier_nightmare_player:AllowIllusionDuplicate()
    return true
end

function modifier_nightmare_player:GetTexture()
    return "night_stalker_darkness"
end

function modifier_nightmare_player:OnCreated()
	local parent = self:GetParent()
	if parent:GetDayTimeVisionRange() % 100 ~= 1 then
		parent:SetDayTimeVisionRange(0)
		parent:SetNightTimeVisionRange(0)
	end
end

function modifier_nightmare_player:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end

function modifier_nightmare_player:GetModifierPercentageCooldown()
    return 10
end