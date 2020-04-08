require("lib/my")



function cast_rock(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    ProjectileManager:CreateTrackingProjectile({
        Ability = ability,
        Target = target,
        Source = caster,
        EffectName = "particles/neutral_fx/mud_golem_hurl_boulder.vpcf",
        iMoveSpeed = 1500,
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
        bDodgeable = false,
        flExpireTime = GameRules:GetGameTime() + 3.0,
    })

    caster:EmitSound("Brewmaster_Earth.Boulder.Cast")
end



function on_rock_hit(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    target:EmitSound("Brewmaster_Earth.Boulder.Target")

    target:InterruptChannel()
    target:Interrupt()

    local damage = ability:GetSpecialValueFor("damage")

    ApplyDamage({
		ability = ability,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PHYSICAL,
		victim = target
    })
    
    ability:SpendCharge()
end
