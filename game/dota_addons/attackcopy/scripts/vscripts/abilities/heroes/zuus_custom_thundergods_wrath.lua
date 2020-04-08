require("lib/my")
require("lib/timers")



zuus_custom_thundergods_wrath = class({})


function zuus_custom_thundergods_wrath:IsStealable()
    return false
end


if IsServer() then
    function zuus_custom_thundergods_wrath:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "modifier_zuus_custom_thundergods_wrath", {})
    end
end



LinkLuaModifier("modifier_zuus_custom_thundergods_wrath", "abilities/heroes/zuus_custom_thundergods_wrath.lua", LUA_MODIFIER_MOTION_NONE)

modifier_zuus_custom_thundergods_wrath = class({})


function modifier_zuus_custom_thundergods_wrath:IsBuff()
    return true
end


if IsServer() then
    function modifier_zuus_custom_thundergods_wrath:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        }
    end


    function modifier_zuus_custom_thundergods_wrath:OnAbilityExecuted(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
		local caster = self:GetCaster()

        local used_ability = keys.ability
    
        local cursor = used_ability:GetCursorPosition()
    
        local casts = ability:GetSpecialValueFor("casts")
        local interval = ability:GetSpecialValueFor("interval")
		
        if used_ability 
            and keys.unit == parent 
            and not used_ability:IsItem() 
            and used_ability:GetAbilityType() ~= 1
            and used_ability:GetName() ~= "zuus_cloud" then
    
            local count = 0
            Timers:CreateTimer(
                interval,
                function()
                    if used_ability and parent:IsAlive() then  -- test again, object may have been deleted.
                        if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
                            parent:SetCursorCastTarget(keys.target)
                        elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
                            parent:SetCursorPosition(cursor)
                        else
                            parent:SetCursorTargetingNothing(true)
                        end
    
                        parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                        used_ability:OnSpellStart()
    
                        count = count + 1
                        if casts > count then
                            return interval
                        end

                    end
                end

            )

            self:Destroy()
        end
    end
end

