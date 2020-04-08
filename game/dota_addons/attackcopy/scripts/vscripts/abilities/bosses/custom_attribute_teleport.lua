require("lib/my")
require("lib/timers")
require("abilities/bosses/custom_attribute_focus")



custom_attribute_teleport = class({})


if IsServer() then
    function custom_attribute_teleport:StartEffect()
        local caster = self:GetCaster()
        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:ReleaseParticleIndex(effect)

        caster:EmitSound("Hero_Antimage.Blink_out")
    end


    function custom_attribute_teleport:EndEffect()
        Timers:CreateTimer(
            0.05,
            function()
                local caster = self:GetCaster()
                local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
                ParticleManager:ReleaseParticleIndex(effect)
				
                caster:EmitSound("Hero_Antimage.Blink_in")
				caster:CastAbilityNoTarget(caster:FindAbilityByName("custom_attribute_blow"), -1)
            end
        )
    end


    function custom_attribute_teleport:OnSpellStart()
        local target = random_from_table(self:GetValidTargets())
        if target then
            self:StartEffect()
            local caster = self:GetCaster()
            local target_pos = target:GetAbsOrigin()
            local new_pos = target_pos + RandomVector(300)
            caster:SetAbsOrigin(new_pos)
            local new_direction = (target_pos - new_pos):Normalized()
            caster:SetForwardVector(new_direction)

            FindClearSpaceForUnit(caster, new_pos, true)
            self:EndEffect()
        end
    end


    function custom_attribute_teleport:GetValidTargets()
        local valid_targets = {}
        local caster = self:GetCaster()
        local current_attribute = get_attribute_focus(caster)
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
        for _, unit in ipairs(units) do
            if unit:IsRealHero() and unit:IsAlive() then
                table.insert(valid_targets, unit)
            end
        end

        return valid_targets
    end
end





