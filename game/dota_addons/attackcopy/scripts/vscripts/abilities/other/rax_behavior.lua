require("lib/my")



custom_rax_behavior = class({})

function custom_rax_behavior:OnSpellStart()
	local caster = self:GetCaster()
    caster:FindModifierByName("modifier_rax_behavior"):ForceRefresh()
end

LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)
modifier_rax_behavior = class({})

function modifier_rax_behavior:IsHidden()
    return true
end
function modifier_rax_behavior:IsPurgable()
	return false
end

if IsServer() then
	function modifier_rax_behavior:OnCreated(keys)
		self.parent = self:GetParent()
		self.owner = self:GetCaster()
		self.team = self.parent:GetTeamNumber()
		self.ability = self.parent:FindAbilityByName("custom_rax_behavior")
		
		self.unitName = keys.name
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.duration = self.ability:GetSpecialValueFor("duration")
		self.target = self.parent:GetAbsOrigin()
		self:StartIntervalThink(self.interval)
	end
	function modifier_rax_behavior:OnRefresh(keys)
		self.target = self.owner:GetAbsOrigin()
		local fx = ParticleManager:CreateParticle("particles/ui_mouseactions/ping_waypoint.vpcf", PATTACH_WORLDORIGIN, self.owner)
		ParticleManager:SetParticleControl(fx, 0, self.target)
		ParticleManager:SetParticleControl(fx, 5, Vector(3, 0, 0))
		ParticleManager:SetParticleControl(fx, 7, Vector(10, 255, 10))
		
	end
	function modifier_rax_behavior:OnIntervalThink()
		local unit = CreateUnitByName(self.unitName, self.parent:GetAbsOrigin() + Vector(100, 0, 0), true, self.parent, self.owner, self.team)
		unit:SetControllableByPlayer(self.owner:GetPlayerID(), true)
		unit:SetTeam(self.team)
		unit:SetOwner(self.owner)
		unit:AddNewModifier(self.parent, self.ability, "modifier_generic_summon_timer", {
			duration = self.duration})
		FindClearSpaceForUnit(unit, self.parent:GetAbsOrigin()+ Vector(100, 0, 0), false)
		Timers:CreateTimer(
			0.25, 
			function()
				unit:MoveToPositionAggressive(self.target)
			end
		)
	end
end



