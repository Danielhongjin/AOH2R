require("lib/my")
require("lib/timers")


LinkLuaModifier("modifier_grimstroke_custom_soulstore_buff", "abilities/heroes/grimstroke_custom_soulstore.lua", LUA_MODIFIER_MOTION_NONE)



local function get_stack_count(caster, modifier)
    if caster:HasModifier(modifier) then
        return caster:GetModifierStackCount(modifier, caster)
    end
    return 0
end


function on_ability_executed(keys)
    local caster = keys.caster
    local ability = keys.ability
    local modifier = keys.modifier
    local used_ability = keys.event_ability

    local max_stack = ability:GetSpecialValueFor("max_stack")

    if used_ability
        and not used_ability:IsItem()
        and used_ability:GetCaster() == caster
        and used_ability ~= ability
        and get_stack_count(caster, modifier) < max_stack then

        increase_modifier(caster, caster, ability, modifier)
    end
end


function cast_grimstroke_custom_soulstore(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    local modifier = keys.modifier
    local effect_modifier = keys.effect_modifier

    local stack_count = get_stack_count(caster, modifier)

    if stack_count > 0 then
        target:EmitSound("Hero_Grimstroke.SoulChain.Cast")

        local duration = ability:GetSpecialValueFor("duration")

        if caster:IsOpposingTeam(target:GetTeam()) then
            local damage = ability:GetSpecialValueFor("damage") * stack_count

            target:AddNewModifier(caster, ability, "modifier_grimstroke_custom_soulstore_buff", {
                duration = duration,
                damage = damage
            })
        else
            local heal = ability:GetSpecialValueFor("heal") * stack_count

            target:AddNewModifier(caster, ability, "modifier_grimstroke_custom_soulstore_buff", {
                duration = duration,
                heal = heal
            })
        end

        caster:RemoveModifierByName(modifier)
    else
        caster:Interrupt()
        caster:InterruptChannel()
        ability:RefundManaCost()
        ability:EndCooldown()
    end
end




modifier_grimstroke_custom_soulstore_buff = class({})



function modifier_grimstroke_custom_soulstore_buff:IsHidden()
    return false
end


function modifier_grimstroke_custom_soulstore_buff:GetEffectName()
    return "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf"
end


if IsServer() then
    function modifier_grimstroke_custom_soulstore_buff:OnCreated(table)
        self.damage = table.damage or 0
        self.heal = table.heal or 0

        self.interval = self:GetAbility():GetSpecialValueFor("interval")

        self.tick_amount = self:GetDuration() / self.interval

        self.tick_damage = self.damage / self.tick_amount
        self.tick_heal = self.heal / self.tick_amount

        self:StartIntervalThink(self.interval)
    end


    function modifier_grimstroke_custom_soulstore_buff:OnIntervalThink()
        local parent = self:GetParent()
        local caster = self:GetCaster()

        if self.tick_damage > 0 then
            local ability = self:GetAbility()
            ApplyDamage({
                ability = ability,
                attacker = caster,
                damage = self.tick_damage,
                damage_type = ability:GetAbilityDamageType(),
                victim = parent
            })
        end

        if self.tick_heal > 0 then
            parent:Heal(self.tick_heal, caster)
        end
    end
end
