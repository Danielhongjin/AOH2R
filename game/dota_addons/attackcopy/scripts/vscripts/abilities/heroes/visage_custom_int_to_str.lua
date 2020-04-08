

visage_custom_int_to_str = class({})


function visage_custom_int_to_str:IsStealable()
    return false
end


function visage_custom_int_to_str:OnToggle()
    local caster = self:GetCaster()

    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_visage_custom_int_to_str", {})
        caster:EmitSound("Hero_Morphling.MorphStrength")
    else
        caster:RemoveModifierByName("modifier_visage_custom_int_to_str")
        caster:StopSound("Hero_Morphling.MorphStrength")
    end
end



LinkLuaModifier("modifier_visage_custom_int_to_str", "abilities/heroes/visage_custom_int_to_str.lua", LUA_MODIFIER_MOTION_NONE)

modifier_visage_custom_int_to_str = class({})


function modifier_visage_custom_int_to_str:GetEffectName()
    return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end


if IsServer() then
    function modifier_visage_custom_int_to_str:OnCreated(keys)
        self:StartIntervalThink(1 / self:GetAbility():GetSpecialValueFor("stats_per_second"))
    end


    function modifier_visage_custom_int_to_str:OnIntervalThink()
        local parent = self:GetParent()

        if parent:GetBaseIntellect() > 1 then
            parent:ModifyIntellect(-1)
            parent:ModifyStrength(1)
        end
    end
end
