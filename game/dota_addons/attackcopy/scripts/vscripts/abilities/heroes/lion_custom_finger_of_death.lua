require("lib/timers")



lion_custom_finger_of_death = class({})


function lion_custom_finger_of_death:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end


if IsServer() then
    function lion_custom_finger_of_death:GetTargets()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if caster:HasScepter() then
            return FindUnitsInRadius(
                caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                self:GetSpecialValueFor("splash_radius_scepter"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0,
                FIND_ANY_ORDER,
                false
            )
        end

        local targets = {}
        table.insert(targets, target)

        return targets
    end


    function lion_custom_finger_of_death:OnSpellStart()
        local caster = self:GetCaster()

        self.base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
        self.damage_per_use = self:GetSpecialValueFor("damage_per_use")
        self.damage_delay = self:GetSpecialValueFor("damage_delay")

        self.stack_modifier_name = "modifier_lion_custom_finger_of_death_bonus"

        self.damage = self.base_damage

        local modifier_handler = caster:FindModifierByName(self.stack_modifier_name)
        if modifier_handler then
            local count = modifier_handler:GetStackCount()
            self.damage = self.damage + count
            modifier_handler:SetStackCount(count + self.damage_per_use)
        else
            modifier_handler = caster:AddNewModifier(caster, self, self.stack_modifier_name, {})
            modifier_handler:SetStackCount(self.damage_per_use)
        end

        local targets = self:GetTargets()
        for _, target in ipairs(targets) do
            self:FingerTarget(target)
        end
    end


    function lion_custom_finger_of_death:FingerTarget(target)
        local caster = self:GetCaster()

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)

        Timers:CreateTimer(
            self.damage_delay,
            function()
                if not target:IsMagicImmune() then
                    target:EmitSound("Hero_Lion.FingerOfDeathImpact")

                    ApplyDamage({
                        ability = self,
                        attacker = caster,
                        damage = self.damage,
                        damage_type = self:GetAbilityDamageType(),
                        victim = target
                    })
                end
            end
        )
    end
end




LinkLuaModifier("modifier_lion_custom_finger_of_death_bonus", "abilities/heroes/lion_custom_finger_of_death.lua", LUA_MODIFIER_MOTION_NONE)


modifier_lion_custom_finger_of_death_bonus = class({})

function modifier_lion_custom_finger_of_death_bonus:IsPermanent()
    return true
end

