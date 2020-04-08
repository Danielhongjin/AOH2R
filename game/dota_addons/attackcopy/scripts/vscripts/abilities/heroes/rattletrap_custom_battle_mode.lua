


rattletrap_custom_battle_mode = class({})


if IsServer() then
    function rattletrap_custom_battle_mode:OnToggle()
        local caster = self:GetCaster()
        caster:EmitSound("Hero_Rattletrap.Power_Cogs")

        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_battle_mode", {})

            if talent_value(caster, "rattletrap_custom_bonus_unique_3") > 0 then
                caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_battle_mode_talent_armor", {})
            end

            if talent_value(caster, "rattletrap_custom_bonus_unique_4") > 0 then
                caster:AddNewModifier(caster, self, "modifier_rattletrap_custom_battle_mode_talent_magic_res", {})
            end
        else
            caster:RemoveModifierByName("modifier_rattletrap_custom_battle_mode")
            caster:RemoveModifierByName("modifier_rattletrap_custom_battle_mode_talent_armor")
            caster:RemoveModifierByName("modifier_rattletrap_custom_battle_mode_talent_magic_res")
        end
    end
end



LinkLuaModifier("modifier_rattletrap_custom_battle_mode", "abilities/heroes/rattletrap_custom_battle_mode.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_battle_mode = class({})


function modifier_rattletrap_custom_battle_mode:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end
function modifier_rattletrap_custom_battle_mode:IsPurgable()
	return false
end

function modifier_rattletrap_custom_battle_mode:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end


function modifier_rattletrap_custom_battle_mode:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_magic_res")
end


function modifier_rattletrap_custom_battle_mode:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("slow")
end


function modifier_rattletrap_custom_battle_mode:GetModifierModelScale()
    return 50
end



LinkLuaModifier("modifier_rattletrap_custom_battle_mode_talent_armor", "abilities/heroes/rattletrap_custom_battle_mode.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_battle_mode_talent_armor = class({})


function modifier_rattletrap_custom_battle_mode_talent_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_rattletrap_custom_battle_mode_talent_armor:IsPurgable()
	return false
end

function modifier_rattletrap_custom_battle_mode_talent_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("talent_armor")
end



LinkLuaModifier("modifier_rattletrap_custom_battle_mode_talent_magic_res", "abilities/heroes/rattletrap_custom_battle_mode.lua", LUA_MODIFIER_MOTION_NONE)

modifier_rattletrap_custom_battle_mode_talent_magic_res = class({})


function modifier_rattletrap_custom_battle_mode_talent_magic_res:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end

function modifier_rattletrap_custom_battle_mode_talent_magic_res:IsPurgable()
	return false
end
function modifier_rattletrap_custom_battle_mode_talent_magic_res:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("talent_magic_res")
end
