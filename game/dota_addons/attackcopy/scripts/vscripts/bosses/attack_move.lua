function Spawn(entityKeyValues)
	if thisEntity:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		thisEntity:SetContextThink("AIThink", AIThink, 0)
	end
end


function AIThink()

    local ancient = Entities:FindByName(nil, "dota_goodguys_fort")
	
    if ancient:IsAlive() and thisEntity:IsAlive() then
		if not thisEntity:IsInvisible() and not thisEntity:IsChanneling() and thisEntity:GetCurrentActiveAbility() == nil and not thisEntity:IsCommandRestricted() and not thisEntity:IsAttacking() then
			if (CalcDistanceBetweenEntityOBB(thisEntity, ancient) > 800) then
				if not thisEntity:IsDisarmed() then
					local attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = ancient:GetAbsOrigin()
					}
					ExecuteOrderFromTable(attackOrder)
				else 
					local attackOrder = {
						UnitIndex = thisEntity:entindex(), 
						OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
						Position = thisEntity:GetAbsOrigin()
					}
					ExecuteOrderFromTable(attackOrder)
				end
			end
		end
    end

	return 1
end