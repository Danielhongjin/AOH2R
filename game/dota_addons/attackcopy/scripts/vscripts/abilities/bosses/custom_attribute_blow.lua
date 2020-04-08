require("abilities/bosses/custom_attribute_focus")



custom_attribute_blow = class({})


if IsServer() then
    function custom_attribute_blow:OnSpellStart()
        local caster = self:GetCaster()

        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, 0, false)
        for _, unit in ipairs(units) do
            self:DealDamage(unit)
        end
    end


    function custom_attribute_blow:DealDamage(unit)
        local caster = self:GetCaster()

        local base_damage = self:GetSpecialValueFor("base_damage")

        local pct_damage = self:GetSpecialValueFor("life_damage")
        local stun_duration = self:GetSpecialValueFor("stun")

        if unit:IsRealHero() and unit.GetPrimaryAttribute and unit:GetPrimaryAttribute() == get_attribute_focus(caster) then
            pct_damage = self:GetSpecialValueFor("life_damage_if_att")
            stun_duration = self:GetSpecialValueFor("stun_if_att")
        end

        local damage = base_damage + (unit:GetHealth() * pct_damage * 0.01)

        ApplyDamage({
            ability = self,
            attacker = caster,
            damage = damage,
            damage_type = self:GetAbilityDamageType(),
            victim = unit
        })

        unit:AddNewModifier(caster, self, "modifier_custom_attribute_blow_stun", {
            duration = stun_duration
        })
    end
end


LinkLuaModifier("modifier_custom_attribute_blow_stun", "abilities/bosses/custom_attribute_blow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_blow_stun = class({})


function modifier_custom_attribute_blow_stun:IsDebuff()
    return true
end


function modifier_custom_attribute_blow_stun:IsStunDebuff()
    return true
end


function modifier_custom_attribute_blow_stun:IsPurgable()
    return true
end


function modifier_custom_attribute_blow_stun:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end


function modifier_custom_attribute_blow_stun:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end


function modifier_custom_attribute_blow_stun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end


function modifier_custom_attribute_blow_stun:GetOverrideAnimation(keys)
	return ACT_DOTA_DISABLED
end


function modifier_custom_attribute_blow_stun:CheckState()
	return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end

