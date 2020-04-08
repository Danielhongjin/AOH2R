require("lib/my")

custom_reincarnation = class({})

function custom_reincarnation:GetIntrinsicModifierName()
    return "modifier_custom_reincarnation"
end

LinkLuaModifier("modifier_custom_reincarnation", "abilities/bosses/custom_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)
modifier_custom_reincarnation = class({})

function modifier_custom_reincarnation:IsHidden()
	return true
end


if IsServer() then



function modifier_custom_reincarnation:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end


function modifier_custom_reincarnation:OnCreated(keys)
	local parent = self:GetParent()
	self.invincibility_duration = self:GetAbility():GetSpecialValueFor("duration")

end


function modifier_custom_reincarnation:OnTakeDamage(keys)
	local attacker = keys.attacker
	local unit = keys.unit
	local ability = self:GetAbility()
	local parent = self:GetParent()
	if parent == unit and ability:IsCooldownReady() and parent:GetHealth() < 1  then
		parent:AddNewModifier(parent, self:GetAbility(), "modifier_custom_reincarnation_angry", {duration = self.invincibility_duration})
		ability_start_true_cooldown(ability)
	end
end




end
LinkLuaModifier("modifier_custom_reincarnation_angry", "abilities/bosses/custom_reincarnation.lua", LUA_MODIFIER_MOTION_NONE)
modifier_custom_reincarnation_angry = class({})
if IsServer() then




end
function modifier_custom_reincarnation_angry:GetTexture()
	return "plain_ring_invincibility"
end
function modifier_custom_reincarnation_angry:GetEffectName()
	return "particles/world_shrine/radiant_shrine_regen.vpcf"
end

function modifier_custom_reincarnation_angry:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end