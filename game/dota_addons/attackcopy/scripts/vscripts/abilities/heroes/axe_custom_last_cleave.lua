require("lib/my")
require("lib/timers")


function cast_last_cleave(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local base_damage = ability:GetSpecialValueFor("base_damage")
    local str_multiply = ability:GetSpecialValueFor("str_multiply")

    local caster_str = caster:GetStrength()

    local damage = base_damage + (caster_str * str_multiply)

    ApplyDamage({
        ability = ability,
        attacker = caster,
        damage = damage,
        damage_type = value_if_scepter(caster, DAMAGE_TYPE_PURE, ability:GetAbilityDamageType()),
        victim = target
    })
	local target_location = target:GetAbsOrigin() 
	local culling_kill_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControlEnt(culling_kill_particle, 8, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:ReleaseParticleIndex(culling_kill_particle)
    Timers:CreateTimer(
        0.25, 
        function()
            if not target:IsAlive() then
                if ability:GetCooldownTimeRemaining() > 0 then
                    ability:EndCooldown()
                end
            end
            return nil
        end
    )
end

function refresh_culling(keys)
	local culling_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_boost_glow_inner.vpcf", PATTACH_CUSTOMORIGIN, keys.caster)
	ParticleManager:SetParticleControlEnt(culling_particle, 0, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(culling_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(culling_particle)
	keys.ability:EndCooldown()
end
