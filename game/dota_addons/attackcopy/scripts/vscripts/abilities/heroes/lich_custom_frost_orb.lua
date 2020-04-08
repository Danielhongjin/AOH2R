

lich_custom_frost_orb = class({})


if IsServer() then
    function lich_custom_frost_orb:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        caster:EmitSound("Hero_Lich.ChainFrost")

        ProjectileManager:CreateTrackingProjectile({
            Ability = self,
            Target = target,
            Source = caster,
            EffectName = "particles/units/heroes/hero_lich/lich_chain_frost.vpcf",
            iMoveSpeed = 1700,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDodgeable = false,
            flExpireTime = GameRules:GetGameTime() + 8.0,
        })
    end


    function lich_custom_frost_orb:OnProjectileHit(target, location)
        local caster = self:GetCaster()

        target:EmitSound("Hero_Lich.ChainFrostImpact.Hero")

        local base_damage = self:GetSpecialValueFor("damage")
        local int_multiplier = self:GetSpecialValueFor("int_multiplier")
        local int_damage = caster:GetIntellect() * int_multiplier

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = base_damage + int_damage,
            damage_type = self:GetAbilityDamageType(),
            victim = target
        })
    end
end
