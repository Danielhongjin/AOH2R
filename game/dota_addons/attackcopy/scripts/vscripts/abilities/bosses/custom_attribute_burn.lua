require("abilities/bosses/custom_attribute_focus")


custom_attribute_burn = class({})


function custom_attribute_burn:GetIntrinsicModifierName()
    return "modifier_custom_attribute_burn_aura"
end



LinkLuaModifier("modifier_custom_attribute_burn_aura", "abilities/bosses/custom_attribute_burn.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_burn_aura = class({})


function modifier_custom_attribute_burn_aura:IsHidden()
    return true
end


if IsServer() then
    function modifier_custom_attribute_burn_aura:OnCreated(keys)
        local ability = self:GetAbility()
        self.radius = ability:GetSpecialValueFor("radius")
        self.target_type = ability:GetAbilityTargetType()
        self.target_team = ability:GetAbilityTargetTeam()
        self.target_flags = ability:GetAbilityTargetFlags()
    end


    function modifier_custom_attribute_burn_aura:IsAura()
        return true
    end


    function modifier_custom_attribute_burn_aura:GetAuraRadius()
        return self.radius
    end


    function modifier_custom_attribute_burn_aura:GetAuraSearchTeam()
        return self.target_team
    end


    function modifier_custom_attribute_burn_aura:GetAuraSearchType()
        return self.target_type
    end


    function modifier_custom_attribute_burn_aura:GetAuraSearchFlags()
        return self.target_flags
    end


    function modifier_custom_attribute_burn_aura:GetModifierAura()
        return "modifier_custom_attribute_burn_debuff"
    end
end



LinkLuaModifier("modifier_custom_attribute_burn_debuff", "abilities/bosses/custom_attribute_burn.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_attribute_burn_debuff = class({})


function modifier_custom_attribute_burn_debuff:IsDebuff()
    return true
end


if IsServer() then
    function modifier_custom_attribute_burn_debuff:OnCreated(keys)
        local ability = self:GetAbility()

        self.ticks_per_sec = ability:GetSpecialValueFor("ticks_per_sec")
        self.attribute_mult = (ability:GetSpecialValueFor("attribute_mult") / self.ticks_per_sec) * 0.01
        self.attribute_mult_if_att = (ability:GetSpecialValueFor("attribute_mult_if_att") / self.ticks_per_sec) * 0.01

        self.tick_interval = 1 / self.ticks_per_sec

        local parent = self:GetParent()
        if parent and parent.GetPrimaryAttribute and parent.GetPrimaryStatValue then
            self:StartIntervalThink(self.tick_interval)
        end
    end


    function modifier_custom_attribute_burn_debuff:OnIntervalThink()
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local att_mult = self.attribute_mult

        if get_attribute_focus(caster) == parent:GetPrimaryAttribute() then
            att_mult = self.attribute_mult_if_att
        end

        local damage = parent:GetPrimaryStatValue() * att_mult

        ApplyDamage({
            ability = ability,
            attacker = caster,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            victim = parent
        })
    end
end
