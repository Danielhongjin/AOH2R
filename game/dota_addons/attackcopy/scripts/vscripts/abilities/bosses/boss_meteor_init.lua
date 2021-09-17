LinkLuaModifier("modifier_boss_meteor", "abilities/bosses/boss_meteor_init.lua", LUA_MODIFIER_MOTION_NONE)

function init(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNewModifier(caster, ability, "modifier_boss_meteor", {duration = -1})
end


modifier_boss_meteor = class({})

function modifier_boss_meteor:IsPurgable()
	return false
end

function modifier_boss_meteor:IsHidden()
	return true
end

function modifier_boss_meteor:RemoveOnDeath()
	return false
end

function modifier_boss_meteor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
end
if IsServer() then
	function modifier_boss_meteor:OnCreated()
		local parent = self:GetParent()
		EmitSoundOnLocationWithCaster(parent:GetAbsOrigin(), "Hero_Invoker.ChaosMeteor.Cast", parent)
		self.particle = ParticleManager:CreateParticle("particles/custom/boss_meteor_fire_trail.vpcf", PATTACH_POINT, parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.particle, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end

	function modifier_boss_meteor:OnDestroy()
		ParticleManager:DestroyParticle(self.particle, false)
		EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Invoker.ChaosMeteor.Destroy", self:GetParent())
	end
end
function modifier_boss_meteor:GetModifierMoveSpeed_AbsoluteMin()
	return self:GetAbility():GetSpecialValueFor("minimum_movespeed")
end