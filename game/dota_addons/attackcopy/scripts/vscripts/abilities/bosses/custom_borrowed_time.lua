require("lib/popup")


LinkLuaModifier("modifier_custom_borrowed_time", "abilities/bosses/custom_borrowed_time.lua", LUA_MODIFIER_MOTION_NONE)


custom_borrowed_time = class({})


if IsServer() then
    function custom_borrowed_time:OnSpellStart()
        local caster = self:GetCaster()

        caster:EmitSound("Hero_Abaddon.BorrowedTime")

        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "modifier_custom_borrowed_time", {
            duration = duration
        })

    end
end



modifier_custom_borrowed_time = class({})


function modifier_custom_borrowed_time:IsBuff()
    return true
end


function modifier_custom_borrowed_time:GetEffectName()
    return "particles/units/heroes/hero_abaddon/abaddon_borrowed_time.vpcf"
end


function modifier_custom_borrowed_time:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end


function modifier_custom_borrowed_time:GetStatusEffectName()
    return "particles/status_fx/status_effect_abaddon_borrowed_time.vpcf"
end


function modifier_custom_borrowed_time:StatusEffectPriority()
    return 20
end


function modifier_custom_borrowed_time:GetTexture()
    return "abaddon_borrowed_time"
end


if IsServer() then
    function modifier_custom_borrowed_time:OnCreated()
        self.heal_factor = self:GetAbility():GetSpecialValueFor("heal_factor") * 0.01
    end


    function modifier_custom_borrowed_time:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        }
    end


    function modifier_custom_borrowed_time:GetModifierIncomingDamage_Percentage(keys)
        local parent = self:GetParent()

        local heal = keys.damage * self.heal_factor
        parent:Heal(heal, parent)

        create_popup({
            target = parent,
            value = heal,
            color = Vector(0, 230, 0),
            type = "heal"
        })

        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(effect)

        return -100
    end
end
