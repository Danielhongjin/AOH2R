

queenofpain_custom_shadow_strike = class({})


if IsServer() then
    function queenofpain_custom_shadow_strike:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        caster:EmitSound("Hero_QueenOfPain.ShadowStrike")

        local projectile_speed = 900

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 3, Vector(projectile_speed, 0, 0))
        ParticleManager:ReleaseParticleIndex(particle)

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf",
            iMoveSpeed = projectile_speed,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 10,
        })
    end


    function queenofpain_custom_shadow_strike:OnProjectileHit(target, location)
        local caster = self:GetCaster()

        target:EmitSound("Hero_QueenOfPain.ShadowStrike.Target")

        local damage = self:GetSpecialValueFor("strike_damage")

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, target, damage, nil)

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            victim = target
        })

        target:AddNewModifier(caster, self, "modifier_queenofpain_custom_shadow_strike", {
            duration = self:GetSpecialValueFor("duration")
        })
    end
end



LinkLuaModifier("modifier_queenofpain_custom_shadow_strike", "abilities/heroes/queenofpain_custom_shadow_strike.lua", LUA_MODIFIER_MOTION_NONE)

modifier_queenofpain_custom_shadow_strike = class({})


function modifier_queenofpain_custom_shadow_strike:IsDebuff()
    return true
end


function modifier_queenofpain_custom_shadow_strike:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


if IsServer() then
    function modifier_queenofpain_custom_shadow_strike:OnCreated(keys)
        self.tick_damage = self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor("int_pct_tick") * 0.01

        self:StartIntervalThink(1.0)
    end


    function modifier_queenofpain_custom_shadow_strike:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, parent, self.tick_damage, nil)

        ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = self.tick_damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })
    end
end


function modifier_queenofpain_custom_shadow_strike:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
end


function modifier_queenofpain_custom_shadow_strike:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movement_slow")
end
