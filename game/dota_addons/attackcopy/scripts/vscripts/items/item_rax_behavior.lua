
function RaxSpawn( keys )
	local caster = keys.caster
	local target = keys.target
	local owner = caster:GetOwner()
	local caster_team = caster:GetTeamNumber()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	ability.unit_count = ability.unit_count or 0
	ability.table = ability.table or {}
	local max_units = ability:GetLevelSpecialValueFor("max_units", ability_level)

	if ability.unit_count <= max_units then
	local unit = CreateUnitByName(self.unitName, self.parent:GetAbsOrigin() + Vector(100, 0, 0), true, self.parent, self.owner, self.team)
	unit:SetControllableByPlayer(self.owner:GetPlayerID(), true)
	unit:SetTeam(owner:GetTeamNumber())
	unit:SetOwner(owner)
	FindClearSpaceForUnit(unit, self.parent:GetAbsOrigin()+ Vector(100, 0, 0), false)
	Timers:CreateTimer(
		0.25, 
		function()
			unit:MoveToPositionAggressive(self.owner:GetAbsOrigin())
		end
	)
	end
	ability.unit_count = ability.unit_count + 1
end


function RaxRemove( keys )
	local target = keys.target
	local ability = keys.ability
	for i = 1, #ability.holy_persuasion_table do
		if ability.table[i] == target then
			ability.unit_count = ability.holy_persuasion_unit_count - 1
			break
		end
	end
end