require("lib/timers")
require("lib/data")


treant_custom_ultimate_sacrifice = class({})


function treant_custom_ultimate_sacrifice:IsStealable()
    return false
end


function treant_custom_ultimate_sacrifice:OnChannelThink(interval)
    self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
end


if IsServer() then
    function treant_custom_ultimate_sacrifice:OnChannelFinish(interrupted)
        if not interrupted then
            local caster = self:GetCaster()
            local ressurected = self:RessurectAll()

            if ressurected > 0 then
                player_data_modify_value(caster:GetPlayerID(), "saves", ressurected)

                caster:EmitSound("Hero_Treant.Overgrowth.Cast")

                self:DestroyTrees()
                self:Suicide(0.05)

                self:StartCooldown(self:GetSpecialValueFor("base_cooldown") + self:GetSpecialValueFor("extra_cooldown") * ressurected)
            else
                caster:Interrupt()
                caster:InterruptChannel()
                self:RefundManaCost()
                self:EndCooldown()
            end
        end
    end


    function treant_custom_ultimate_sacrifice:RessurectEffect(target)
        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect)

        target:EmitSound("Hero_Treant.Overgrowth.Target")
    end


    function treant_custom_ultimate_sacrifice:RessurectAll()
        local ressurected = 0

        for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:HasSelectedHero(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if not hero:IsAlive() then
                    hero:RespawnUnit()
                    hero:SetHealth(hero:GetMaxHealth())
                    hero:SetMana(hero:GetMaxMana())
                    hero:SetBaseMagicalResistanceValue(25)

                    self:RessurectEffect(hero)

                    ressurected = ressurected + 1
                end
            end
        end

        return ressurected
    end


    function treant_custom_ultimate_sacrifice:Suicide(delay)
        Timers:CreateTimer(
            delay, 
            function()
                local caster = self:GetCaster()
                if caster:IsAlive() then
                    caster:ForceKill(false)
                end
            end
        )
    end


    function treant_custom_ultimate_sacrifice:DestroyTrees()
        GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 3900, false)
    end
end
