require("lib/timers")



function Spawn(entityKeyValues)
    if thisEntity == nil then
        return
    end

    thisEntity.custom_attribute_teleport = thisEntity:FindAbilityByName("custom_attribute_teleport")
    thisEntity.custom_attribute_blow = thisEntity:FindAbilityByName("custom_attribute_blow")

	thisEntity:SetContextThink("AIThink", AIThink, 1.0)
end


function AIThink()
    if thisEntity and thisEntity:IsAlive() then
        if not GameRules:IsGamePaused() then
            if thisEntity.custom_attribute_teleport:IsCooldownReady() and thisEntity.custom_attribute_blow:IsCooldownReady() then

                Timers:CreateTimer(
                    0.3,
                    function()
                        if thisEntity:IsAlive() then
                            ExecuteOrderFromTable({
                                UnitIndex = thisEntity:entindex(),
                                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                                AbilityIndex = thisEntity.custom_attribute_teleport:entindex()
                            })
                        end
                    end
                )


                Timers:CreateTimer(
                    1.0,
                    function()
                        if thisEntity:IsAlive() then
                            ExecuteOrderFromTable({
                                UnitIndex = thisEntity:entindex(),
                                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                                AbilityIndex = thisEntity.custom_attribute_blow:entindex()
                            })
                        end
                    end
                )
            end
        end

        return 1.0
    end
end
