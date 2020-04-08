

LinkLuaModifier("modifier_shadow_demon_custom_soul_catcher_buff", "abilities/heroes/shadow_demon_custom_soul_catcher.lua", LUA_MODIFIER_MOTION_NONE)



function cast_shadow_demon_custom_soul_catcher(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target

    local duration = ability:GetSpecialValueFor("duration")

    target:AddNewModifier(caster, ability, "modifier_shadow_demon_custom_soul_catcher_buff", { duration = duration })
end



modifier_shadow_demon_custom_soul_catcher_buff = class({})


function modifier_shadow_demon_custom_soul_catcher_buff:IsHidden()
    return false
end


function modifier_shadow_demon_custom_soul_catcher_buff:IsDebuff()
    return true
end


function modifier_shadow_demon_custom_soul_catcher_buff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_shadow_demon_custom_soul_catcher_buff:GetEffectName()
    return "particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher_debuff.vpcf"
end


if IsServer() then
    function modifier_shadow_demon_custom_soul_catcher_buff:OnCreated(table)
        local ability = self:GetAbility()

        self.damage = ability:GetSpecialValueFor("damage")
        self.interval = ability:GetSpecialValueFor("interval")

        self.tick_amount = self:GetDuration() / self.interval

        self.tick_damage = self.damage / self.tick_amount

        self:StartIntervalThink(self.interval)
    end


    function modifier_shadow_demon_custom_soul_catcher_buff:OnIntervalThink()
        if self.tick_damage > 0 then
            local ability = self:GetAbility()
            ApplyDamage({
                ability = ability,
                attacker = self:GetCaster(),
                damage = self.tick_damage,
                damage_type = ability:GetAbilityDamageType(),
                victim = self:GetParent()
            })
        end
    end
end
