

custom_aphotic_shield = class({})


if IsServer() then
    function custom_aphotic_shield:OnSpellStart()
        local caster = self:GetCaster()
        local use_at_life_pct = self:GetSpecialValueFor("use_at_life_pct")

        if caster:GetHealthPercent() <= use_at_life_pct then
            caster:AddNewModifier(caster, self, "modifier_custom_aphotic_shield", {
                duration = self:GetSpecialValueFor("duration")
            })
        else
            self:StartCooldown(5.0)
        end
    end
end



LinkLuaModifier("modifier_custom_aphotic_shield", "abilities/bosses/custom_aphotic_shield.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_aphotic_shield = class({})


function modifier_custom_aphotic_shield:IsBuff()
    return true
end


if IsServer() then
    function modifier_custom_aphotic_shield:OnCreated(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()

        self.damage_radius = ability:GetSpecialValueFor("radius")
        self.damage_percentage = ability:GetSpecialValueFor("percentage") * 0.01

        self.total_damage = 0

        parent:EmitSound("Hero_Abaddon.AphoticShield.Cast")

        local shield_size = 200
        self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(self.particle, 1, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 2, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 4, Vector(shield_size, 0, shield_size))
        ParticleManager:SetParticleControl(self.particle, 5, Vector(shield_size, 0, 0))
        ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
    end


    function modifier_custom_aphotic_shield:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()

        parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy")

        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)

        local damage = self.total_damage * self.damage_percentage

        local units = FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self.damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)

        for _, unit in ipairs(units) do
            ApplyDamage({
                ability = ability,
                attacker = parent,
                damage = damage,
                damage_type = ability:GetAbilityDamageType(),
                victim = unit
            })
        end
    end


    function modifier_custom_aphotic_shield:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end


    function modifier_custom_aphotic_shield:OnTakeDamage(keys)
        local parent = self:GetParent()
        if keys.unit == parent then
            local damage = keys.damage

            self.total_damage = self.total_damage + damage

            create_popup({
                target = parent,
                value = damage,
                color = Vector(47, 80, 80),
                type = "resist"
            })
        end
    end
end
