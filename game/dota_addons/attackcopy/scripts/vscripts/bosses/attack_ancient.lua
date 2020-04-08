

function Spawn(entityKeyValues)
	thisEntity:SetContextThink("AIThink", AIThink, 0.25)
end


function AIThink()

    local ancient = Entities:FindByName(nil, "dota_goodguys_fort")

    if ancient:IsAlive() and thisEntity:IsAlive() then
        local attackOrder = {
            UnitIndex = thisEntity:entindex(), 
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = ancient:entindex()
        }

        ExecuteOrderFromTable(attackOrder)
    end

	return 2
end
