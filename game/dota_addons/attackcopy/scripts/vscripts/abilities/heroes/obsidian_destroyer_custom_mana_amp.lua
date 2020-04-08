

obsidian_destroyer_custom_mana_amp = class({})



function obsidian_destroyer_custom_mana_amp:OnSpellStart()
    local caster = self:GetCaster()
	local amp = caster:AddNewModifier(caster, self, "modifier_mana_amp_custom_active", {duration = self:GetSpecialValueFor("duration")})
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end


function obsidian_destroyer_custom_mana_amp:GetIntrinsicModifierName()
    return "modifier_mana_amp_custom"
end


LinkLuaModifier("modifier_mana_amp_custom_active", "abilities/heroes/obsidian_destroyer_custom_mana_amp.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mana_amp_custom_active = class({})


function modifier_mana_amp_custom_active:IsHidden()
    return false
end

function modifier_mana_amp_custom_active:IsPurgable()
	return false
end



function modifier_mana_amp_custom_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_BONUS,
    }
end


function modifier_mana_amp_custom_active:GetModifierManaBonus()
    return self:GetStackCount()
end
function modifier_mana_amp_custom_active:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	self:SetStackCount(ability:GetSpecialValueFor("mana_amp") * parent:GetIntellect())
end

LinkLuaModifier("modifier_mana_amp_custom", "abilities/heroes/obsidian_destroyer_custom_mana_amp.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mana_amp_custom = class({})


function modifier_mana_amp_custom:IsHidden()
    return true
end

function modifier_mana_amp_custom:IsPurgable()
	return false
end


function modifier_mana_amp_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
    }
end


function modifier_mana_amp_custom:GetModifierTotalPercentageManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen_pct")
end
