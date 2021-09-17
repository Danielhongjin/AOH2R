require("lib/popup")

LinkLuaModifier("modifier_shadow_demon_custom_soul_catcher_buff", "abilities/heroes/shadow_demon_custom_soul_catcher.lua", LUA_MODIFIER_MOTION_NONE)

shadow_demon_custom_soul_catcher = class({})

function shadow_demon_custom_soul_catcher:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    target:AddNewModifier(caster, self, "modifier_shadow_demon_custom_soul_catcher_buff", { duration = duration })
end

function shadow_demon_custom_soul_catcher:CastFilterResultTarget(hTarget)
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        return UF_SUCCESS
    else
        if self:GetCaster():GetTeam() ~= hTarget:GetTeam() then
            return UF_SUCCESS
        end
    end
    return UF_FAIL_FRIENDLY
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
    function modifier_shadow_demon_custom_soul_catcher_buff:OnCreated()
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.enemy = true
        if self.caster:GetTeam() == self.parent:GetTeam() then
            self.enemy = false
        end
        self.ability = self:GetAbility()
        local interval = self.ability:GetSpecialValueFor("interval")
        local damage = self.ability:GetSpecialValueFor("damage")
        local tick_amount = self:GetDuration() / interval
        self.tick_damage = damage / tick_amount
        self:StartIntervalThink(interval)
    end

    function modifier_shadow_demon_custom_soul_catcher_buff:OnIntervalThink()
        if self.enemy then
            ApplyDamage({
                ability = self.ability,
                attacker = self.caster,
                damage = self.tick_damage,
                damage_type = self.ability:GetAbilityDamageType(),
                victim = self.parent
            })
        else
            create_popup({
                target = self.parent,
                value = self.tick_damage,
                color = Vector(0, 255, 0),
                type = "heal",
            })	
            self.parent:Heal(self.tick_damage, self.ability)
        end
    end
end
