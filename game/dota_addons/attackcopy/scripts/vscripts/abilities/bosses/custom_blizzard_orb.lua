require("lib/ai")
require("lib/my")

custom_blizzard_orb = class({})


function custom_blizzard_orb:OnSpellStart()
	local caster = self:GetCaster()
	local heroes = ai_alive_heroes()
	for _, hero in ipairs(heroes) do
		local orb = CreateUnitByName("npc_blizzard_orb", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
		orb:SetForceAttackTarget(hero)
		orb:AddNewModifier(
			caster,
			self,
			"modifier_custom_blizzard_orb_behavior", -- modifier name
			{ duration = self:GetSpecialValueFor("duration") } -- kv
		)
	end

end

LinkLuaModifier("modifier_custom_blizzard_orb_behavior", "abilities/bosses/custom_blizzard_orb.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_blizzard_orb_behavior = class({})


function modifier_custom_blizzard_orb_behavior:IsHidden()
    return true
end
function modifier_custom_blizzard_orb_behavior:IsPurgable()
	return false
end

function modifier_custom_blizzard_orb_behavior:OnCreated()
	self.parent = self:GetParent()
	local ability = self:GetAbility()
	local delay = ability:GetSpecialValueFor("delay")
	self.blizzard = self.parent:FindAbilityByName("custom_freezing_field")
	local fx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	Timers:CreateTimer(
		delay,
		function()
			self.parent:CastAbilityNoTarget(self.blizzard, -1)
			self:StartIntervalThink(1)
		end
	)
end

function modifier_custom_blizzard_orb_behavior:OnDestroy()
	local parent = self:GetParent()
	parent:ForceKill(false)
end

function modifier_custom_blizzard_orb_behavior:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_center.vpcf"
end
if IsServer() then
	function modifier_custom_blizzard_orb_behavior:OnIntervalThink()
		if not self.blizzard:IsChanneling() then
			self.parent:CastAbilityNoTarget(self.blizzard, -1)
		end
	end
end