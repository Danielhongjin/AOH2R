require("lib/timers")
require("lib/my")
require("lib/ai")


function degen_ward(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local ward = CreateUnitByName("npc_degen_ward", target:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	FindClearSpaceForUnit(ward, target:GetAbsOrigin(), false)
	ward:AddNewModifier(
			caster,
			self,
			"modifier_degen_ward_effect", -- modifier name
			{duration = ability:GetSpecialValueFor("duration")} -- kv
		)
end


LinkLuaModifier("modifier_degen_ward_effect", "abilities/bosses/boss_invoker_degen_ward.lua", LUA_MODIFIER_MOTION_NONE)
modifier_degen_ward_effect = class({})

function modifier_degen_ward_effect:IsPurgable()
	return false
end

function modifier_degen_ward_effect:IsHidden()
	return true
end


if IsServer() then
	function modifier_degen_ward_effect:OnCreated(keys)
		self.parent = self:GetParent()
		self.fx = ParticleManager:CreateParticle("particles/custom/custom_spirit_ground_aura.vpcf", PATTACH_ABSORIGIN, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)

	end

	function modifier_degen_ward_effect:OnDestroy()
		ParticleManager:DestroyParticle(self.fx, false)
		ParticleManager:ReleaseParticleIndex(self.fx)
		self.parent:ForceKill(false)
	end
end