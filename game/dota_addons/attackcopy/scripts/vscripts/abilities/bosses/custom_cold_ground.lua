require("lib/my")
require("lib/timers")



custom_cold_ground = class({})


if IsServer() then
    function custom_cold_ground:GetCooldown(iLevel)
        local caster = self:GetCaster()

        local caster_health_pct = caster:GetHealthPercent()

        local max_cd_hp_pct = self:GetSpecialValueFor("use_at_hp_pct")

        if caster_health_pct < max_cd_hp_pct then
            local min_cd_hp_pct = self:GetSpecialValueFor("min_cd_hp_pct")

            local min_cd = self:GetSpecialValueFor("min_cd")
            local max_cd = self:GetSpecialValueFor("max_cd")

            local cd_factor = (caster:GetHealthPercent() - min_cd_hp_pct) / max_cd_hp_pct
            local cd = cd_factor * max_cd

            return clamp_value(cd, min_cd, max_cd)
        end

        return self.BaseClass.GetCooldown(self, iLevel)
    end


    function custom_cold_ground:OnSpellStart()
        local caster = self:GetCaster()
        if caster:GetHealthPercent() <= self:GetSpecialValueFor("use_at_hp_pct") then
            local radius = self:GetSpecialValueFor("radius")
            self:CreateAtPos(caster:GetAbsOrigin() + Vector(RandomInt(-radius, radius), RandomInt(-radius, radius), 0))
        end
    end


    function custom_cold_ground:CreateAtPos(pos)
        local ground_effect = self:CreateColdEffect(pos)

        Timers:CreateTimer(
            self:GetSpecialValueFor("delay"),
            function()
                ParticleManager:DestroyParticle(ground_effect, false)
                ParticleManager:ReleaseParticleIndex(ground_effect)
                self:ExplodeAtPos(pos)
            end
        )
    end


    function custom_cold_ground:CreateColdEffect(pos)
        local caster = self:GetCaster()
        local damage_radius = self:GetSpecialValueFor("damage_radius")

        local dummy = create_dummy(caster, pos)

        local ground_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_ice_vortex.vpcf", PATTACH_ABSORIGIN, dummy)
        ParticleManager:SetParticleControl(ground_effect, 1, Vector(damage_radius, 0, 0))
        ParticleManager:SetParticleControl(ground_effect, 5, Vector(damage_radius, 0, 0))
        
        caster:EmitSound("Hero_Ancient_Apparition.IceVortexCast")

        kill_dummy(dummy)

        return ground_effect
    end


    function custom_cold_ground:ExplodeAtPos(pos)
        local caster = self:GetCaster()
        local damage_radius = self:GetSpecialValueFor("damage_radius")

        local dummy = create_dummy(caster, pos)

        local particle = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_ABSORIGIN, dummy)
        ParticleManager:SetParticleControl(particle, 3, Vector(damage_radius, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)
        
        caster:EmitSound("Hero_Crystal.CrystalNova")

        kill_dummy(dummy)


        local base_damage = self:GetSpecialValueFor("base_damage")
        local life_damage = self:GetSpecialValueFor("life_damage") * 0.01


        local units = FindUnitsInRadius(caster:GetTeam(), pos, nil, damage_radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, 0, false)

        for _, unit in ipairs(units) do
            ApplyDamage({
                ability = self,
                attacker = caster,
                damage = base_damage + (unit:GetHealth() * life_damage),
                damage_type = self:GetAbilityDamageType(),
                victim = unit
            })
        end

    end
end


