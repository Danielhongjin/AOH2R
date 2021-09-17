require("lib/my")
LinkLuaModifier("modifier_hidden", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/notifications")
boss_abyssal_underlord_undead_cannon_init = class({})
  
 
function distance(vector1, vector2)
  local dx = vector1.x - vector2.x
  local dy = vector1.y - vector2.y
  return math.sqrt ( dx * dx + dy * dy )
end

function boss_abyssal_underlord_undead_cannon_init:OnSpellStart()	
	local caster = self:GetCaster()
	local highest = 0
	local highest_reference = 0
	local count = 0
	
	local rift = caster:FindAbilityByName("abyssal_underlord_dark_rift")
	local delay = rift:GetSpecialValueFor("teleport_delay")
	local cannon = caster:FindAbilityByName("boss_abyssal_underlord_undead_cannon")
	local paths = {[0] = Entities:FindByName(nil, "path_invader1_1"), 
		[1] = Entities:FindByName(nil, "path_invader2_1"), 
		[2] = Entities:FindByName(nil, "path_invader3_1"), 
		[3] = Entities:FindByName(nil, "path_invader4_1"),
	}
	
	for _, path in ipairs(paths) do
		if distance(caster:GetAbsOrigin(), path:GetAbsOrigin()) > highest then
			highest_reference = count
			highest = distance(caster:GetAbsOrigin(), path:GetAbsOrigin())
			count = count + 1
		end
	end
	
	local target = CreateUnitByName("npc_death_orb", paths[highest_reference]:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	caster:SetCursorCastTarget(target)
	target:AddNewModifier(caster, self, "modifier_hidden", {duration = 5})
	rift:OnSpellStart()
	Timers:CreateTimer(
		delay, 
		function()
			if caster:IsAlive() then
				local structure1 = Entities:FindByName(nil, "structure1")
				local structure2 = Entities:FindByName(nil, "structure2")
				local structure3 = Entities:FindByName(nil, "dota_goodguys_fort")
				if structure1 and structure1:IsAlive() then
					caster:SetCursorCastTarget(structure1)
					
				elseif structure2 and structure2:IsAlive() then
					caster:SetCursorCastTarget(structure2)
				elseif structure3 and structure3:IsAlive() then
					caster:SetCursorCastTarget(structure3)
				end
				Notifications:TopToAll({text="UNDERLORD IS TARGETING YOUR BASE", style={color="red", ["font-size"]="70px"}, duration=5})
				MinimapEvent(2, caster, caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, DOTA_MINIMAP_EVENT_BASE_UNDER_ATTACK, 5)
				cannon:OnSpellStart()
			end
		end
	)
	
end
