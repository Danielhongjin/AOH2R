

LinkLuaModifier("modifier_nyx_assassin_custom_vendetta_invis", "abilities/heroes/nyx_assassin_custom_vendetta.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nyx_assassin_custom_vendetta_crit", "abilities/heroes/nyx_assassin_custom_vendetta.lua", LUA_MODIFIER_MOTION_NONE)




nyx_assassin_custom_vendetta = class({})


function nyx_assassin_custom_vendetta:GetIntrinsicModifierName()
    return "modifier_nyx_assassin_custom_vendetta_crit"
end

function nyx_assassin_custom_vendetta:OnUpgrade()
    caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_nyx_assassin_custom_vendetta_crit")
	caster:AddNewModifier(caster, self, "modifier_nyx_assassin_custom_vendetta_crit", {})
end


function nyx_assassin_custom_vendetta:OnSpellStart()
    local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_nyx_assassin_custom_vendetta_invis", {duration = duration})
end




modifier_nyx_assassin_custom_vendetta_invis = class({})


function modifier_nyx_assassin_custom_vendetta_invis:GetTexture()
    return "nyx_assassin_vendetta"
end


function modifier_nyx_assassin_custom_vendetta_invis:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_CANNOT_MISS] = true,
    }
end


function modifier_nyx_assassin_custom_vendetta_invis:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierInvisibilityLevel()
    return 1
end


function modifier_nyx_assassin_custom_vendetta_invis:OnAttackLanded(keys)
    local attacker = keys.attacker
    if attacker == self:GetParent() then 
        self:Destroy() 
    end
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movement_speed")
end


function modifier_nyx_assassin_custom_vendetta_invis:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("spell_amp")
end




modifier_nyx_assassin_custom_vendetta_crit = class({})


function modifier_nyx_assassin_custom_vendetta_crit:GetTexture()
    return "nyx_assassin_vendetta"
end


function modifier_nyx_assassin_custom_vendetta_crit:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end


function modifier_nyx_assassin_custom_vendetta_crit:OnAttackLanded(keys)
    local attacker = keys.attacker
    if attacker == self:GetParent() then 
        self:SetStackCount(0)
    end
end


function modifier_nyx_assassin_custom_vendetta_crit:OnCreated()
    local ability = self:GetAbility()

    self.max_crit_stack = ability:GetSpecialValueFor("max_crit_stacks")
    self.crit_increase = ability:GetSpecialValueFor("crit_increase")
    self.interval = ability:GetSpecialValueFor("interval")

    self:StartIntervalThink(self.interval)
end


function modifier_nyx_assassin_custom_vendetta_crit:OnIntervalThink()
    if self:GetStackCount() < self.max_crit_stack then
        self:IncrementStackCount()
    end
end


function modifier_nyx_assassin_custom_vendetta_crit:GetModifierPreAttack_CriticalStrike()
    return self.crit_increase * self:GetStackCount()
end
