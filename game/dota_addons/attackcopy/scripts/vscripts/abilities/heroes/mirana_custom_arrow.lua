


mirana_custom_arrow = class({})


function mirana_custom_arrow:GetIntrinsicModifierName()
    return "modifier_mirana_custom_arrow"
end


if IsServer() then
    function mirana_custom_arrow:OnProjectileHit(target, location)
        if target and target:IsAlive() and not target:IsMagicImmune() then
            local caster = self:GetCaster()

            local damage_pct = self:GetSpecialValueFor("damage_pct")

            local damage = caster:GetAverageTrueAttackDamage(target) * damage_pct * 0.01

            ApplyDamage({
                ability = self,
                attacker = caster,
                damage = damage,
                damage_type = self:GetAbilityDamageType(),
                victim = target
            })

            target:EmitSoundParams("Hero_Mirana.ArrowImpact", 0, 0.4, 0)
        end

        return true
    end
end



LinkLuaModifier("modifier_mirana_custom_arrow", "abilities/heroes/mirana_custom_arrow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mirana_custom_arrow = class({})


function modifier_mirana_custom_arrow:IsHidden()
    return true
end


if IsServer() then
    function modifier_mirana_custom_arrow:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK,
        }
    end
    
    
    function modifier_mirana_custom_arrow:OnAttack(keys)
        local attacker = keys.attacker
    
        if attacker ~= self:GetParent() then 
            return 
        end

        local target = keys.target
        local ability = self:GetAbility()


        local direction = (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()

    
        ProjectileManager:CreateLinearProjectile({
            EffectName = "particles/econ/items/mirana/mirana_crescent_arrow/mirana_spell_crescent_arrow.vpcf",
            Ability = ability,
            vSpawnOrigin = attacker:GetOrigin() + Vector(0,0,200), 
            fStartRadius = 100.0,
            fEndRadius = 100.0,
            vVelocity = direction * 800,
            fDistance = 3 * attacker:GetBaseAttackRange(),
            Source = attacker,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bDeleteOnHit = true,
        })

        attacker:EmitSoundParams("Hero_Mirana.ArrowCast", 0, 0.4, 0)
    end

end
