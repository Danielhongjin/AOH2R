

visage_custom_str_to_int = class({})


function visage_custom_str_to_int:IsStealable()
    return false
end


function visage_custom_str_to_int:OnToggle()
    local caster = self:GetCaster()

    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_visage_custom_str_to_int", {})
        caster:EmitSound("Hero_Morphling.MorphStrength")
    else
        caster:RemoveModifierByName("modifier_visage_custom_str_to_int")
        caster:StopSound("Hero_Morphling.MorphStrength")
    end
end



LinkLuaModifier("modifier_visage_custom_str_to_int", "abilities/heroes/visage_custom_str_to_int.lua", LUA_MODIFIER_MOTION_NONE)

modifier_visage_custom_str_to_int = class({})


function modifier_visage_custom_str_to_int:GetEffectName()
    return "particles/units/heroes/hero_morphling/morphling_morph_str.vpcf"
end


if IsServer() then
    function modifier_visage_custom_str_to_int:OnCreated(keys)
        self:StartIntervalThink(1 / self:GetAbility():GetSpecialValueFor("stats_per_second"))
    end


    function modifier_visage_custom_str_to_int:OnIntervalThink()
        local parent = self:GetParent()

        if parent:GetBaseStrength() > 1 then
            parent:ModifyIntellect(1)
            parent:ModifyStrength(-1)
        end
    end
end
