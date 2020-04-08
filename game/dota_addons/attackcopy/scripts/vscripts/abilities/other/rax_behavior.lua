require("lib/my")




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
		self.owner = self:GetAbility():GetCaster()
		self.team = self.parent:GetTeamNumber()
		self.ability = self:GetAbility()
		self.unitName = "npc_dota_creep_goodguys_melee"
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.duration = self.ability:GetSpecialValueFor("duration")
		self:StartIntervalThink(self.interval)
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
				unit:MoveToPositionAggressive(self.owner:GetAbsOrigin())
			end
		)
	end
end



