

LinkLuaModifier("modifier_custom_spell_reflect", "abilities/bosses/custom_spell_reflect.lua", LUA_MODIFIER_MOTION_NONE)


custom_spell_reflect = class({})


function custom_spell_reflect:GetIntrinsicModifierName()
    return "modifier_custom_spell_reflect"
end



modifier_custom_spell_reflect = class({})


function modifier_custom_spell_reflect:IsHidden()
    return true
end


if IsServer() then
    function modifier_custom_spell_reflect:OnCreated()
        self.cooldown = self:GetAbility():GetSpecialValueFor("cooldown")
        self.last_time = 0
    end


    function modifier_custom_spell_reflect:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_REFLECT_SPELL,
        }
    end


    function modifier_custom_spell_reflect:GetReflectSpell(keys)
        local parent = self:GetParent()

        local time = GameRules:GetGameTime()

        if parent:PassivesDisabled() or self.last_time + self.cooldown > time then
            return
        end

        local usedAbility = keys.ability
        local usedAbilityName = usedAbility:GetName()
        local usedAbilityCaster = usedAbility:GetCaster()

        if usedAbilityCaster:GetTeamNumber() == parent:GetTeamNumber() or usedAbility.isReflection then
            return
        end

        local ability = parent:FindAbilityByName(usedAbilityName)

        if not ability then -- spell was never reflected
            ability = parent:AddAbility(usedAbilityName)
            ability:SetStolen(true)
            ability:SetHidden(true)

            ability:SetLevel(usedAbility:GetLevel())

            ability.isReflection = true
        end

        self.last_time = time

        parent:SetCursorCastTarget(usedAbilityCaster)
        ability:OnSpellStart()

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)

        parent:EmitSound("Hero_Antimage.SpellShield.Reflect")
    end
end
