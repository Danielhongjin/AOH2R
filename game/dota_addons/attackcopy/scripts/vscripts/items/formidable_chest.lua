

item_formidable_chest = class({})


function item_formidable_chest:GetIntrinsicModifierName()
    return "modifier_item_formidable_chest"
end




function item_formidable_chest:OnSpellStart()
    local caster = self:GetCaster()

    caster:EmitSound("Item.CrimsonGuard.Cast")

    local units = FindUnitsInRadius(
        caster:GetTeam(), 
        caster:GetAbsOrigin(), 
        nil, 
        self:GetSpecialValueFor("radius"), 
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
        0, 
        0, 
        false
    )
    local duration = self:GetSpecialValueFor("duration")
    for _, unit in ipairs(units) do
        unit:AddNewModifier(caster, self, "modifier_item_formidable_chest_buff", {
            duration = duration
        })
    end

end



LinkLuaModifier("modifier_item_formidable_chest", "items/formidable_chest.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_formidable_chest = class({})


function modifier_item_formidable_chest:IsHidden()
    return true
end

function modifier_item_formidable_chest:IsPurgable()
	return false
end
function modifier_item_formidable_chest:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_formidable_chest:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end


function modifier_item_formidable_chest:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end



LinkLuaModifier("modifier_item_formidable_chest_buff", "items/formidable_chest.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_formidable_chest_buff = class({})


function modifier_item_formidable_chest_buff:GetTexture()
    return "formidable_chest"
end


function modifier_item_formidable_chest_buff:GetEffectName()
    return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end


function modifier_item_formidable_chest_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end


function modifier_item_formidable_chest_buff:GetModifierIncomingDamage_Percentage()
    local ability = self:GetAbility()
    if ability then
        return ability:GetSpecialValueFor("damage_reduction")
    end
end
