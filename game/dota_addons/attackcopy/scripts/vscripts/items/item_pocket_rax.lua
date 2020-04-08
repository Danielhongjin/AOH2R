
LinkLuaModifier("modifier_rax_behavior", "abilities/other/rax_behavior.lua", LUA_MODIFIER_MOTION_NONE)

item_pocket_rax = class({})
if IsServer() then
function item_pocket_rax:CastFilterResultLocation(target)
	local caster = self:GetCaster()
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, target, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, 0, false)
		local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, target, nil, 200, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, 0, 0, false)
	if #units>0 or #buildings>0 then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end

    function item_pocket_rax:OnSpellStart()
        self.target_pos = self:GetCursorPosition()
		local caster = self:GetCaster()
		
		CreateUnitByNameAsync(
            "npc_dota_goodguys_melee_rax_mid",
            self.target_pos,
            true,
            caster,
            nil,
            caster:GetTeamNumber(),
            function(tower)
                tower:SetControllableByPlayer(caster:GetPlayerID(), true)
				tower:SetAbsOrigin(self.target_pos)
				tower:SetOwner(caster)
				tower:AddNewModifier(caster, self, "modifier_rax_behavior", {})
				tower:SetInvulnCount(0)
				self:SpendCharge()
            end
        )
		
    end
end
