

base_tome_class = class({})


if IsServer() then
    function base_tome_class:OnSpellStart()
        local caster = self:GetCaster()

        local bonus = self:GetSpecialValueFor("bonus")
        caster[self.modify_function](caster, bonus)
        caster:CalculateStatBonus()

        if caster:HasModifier(self.modifier_name) then
            local modifier = caster:FindModifierByName(self.modifier_name)
            modifier:SetStackCount(modifier:GetStackCount() + bonus)
        else
            caster:AddNewModifier(caster, self, self.modifier_name, {})
            caster:FindModifierByName(self.modifier_name):SetStackCount(bonus)
        end

        self:SpendCharge()
    end
end



base_modifier_tome_class = class({})


function base_modifier_tome_class:GetTexture()
    return self.texture
end


function base_modifier_tome_class:RemoveOnDeath()
    return false
end


function base_modifier_tome_class:IsPermanent()
    return true
end


function base_modifier_tome_class:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end


function base_modifier_tome_class:OnTooltip()
    return self:GetStackCount()
end



item_tome_str = class(base_tome_class)
item_tome_str.modifier_name = "modifier_tome_str_bonus"
item_tome_str.modify_function = "ModifyStrength"


item_tome_agi = class(base_tome_class)
item_tome_agi.modifier_name = "modifier_tome_agi_bonus"
item_tome_agi.modify_function = "ModifyAgility"


item_tome_int = class(base_tome_class)
item_tome_int.modifier_name = "modifier_tome_int_bonus"
item_tome_int.modify_function = "ModifyIntellect"



LinkLuaModifier("modifier_tome_str_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
modifier_tome_str_bonus = class(base_modifier_tome_class)
modifier_tome_str_bonus.texture = "item_tome_str"


LinkLuaModifier("modifier_tome_agi_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
modifier_tome_agi_bonus = class(base_modifier_tome_class)
modifier_tome_agi_bonus.texture = "item_tome_agi"


LinkLuaModifier("modifier_tome_int_bonus", "items/tomes.lua", LUA_MODIFIER_MOTION_NONE)
modifier_tome_int_bonus = class(base_modifier_tome_class)
modifier_tome_int_bonus.texture = "item_tome_int"
