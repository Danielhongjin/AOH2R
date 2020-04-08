


bloodseeker_custom_rampage = class({})


if IsServer() then
    function bloodseeker_custom_rampage:OnSpellStart()
        local caster = self:GetCaster()

        caster:AddNewModifier(caster, self, "modifier_bloodseeker_custom_rampage", {
            duration = self:GetSpecialValueFor("duration")
        })
    end
end



LinkLuaModifier("modifier_bloodseeker_custom_rampage", "abilities/heroes/bloodseeker_custom_rampage.lua", LUA_MODIFIER_MOTION_NONE)

modifier_bloodseeker_custom_rampage = class({})


function modifier_bloodseeker_custom_rampage:IsBuff()
    return true
end


function modifier_bloodseeker_custom_rampage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
end


function modifier_bloodseeker_custom_rampage:GetModifierMoveSpeed_Absolute()
    return 550
end


function modifier_bloodseeker_custom_rampage:GetModifierDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("increased_damage")
end


if IsServer() then
    function modifier_bloodseeker_custom_rampage:OnCreated(keys)
        local ability = self:GetAbility()
        self.max_hp = ability:GetSpecialValueFor("max_hp")

        self:StartIntervalThink(0.1)
    end


    function modifier_bloodseeker_custom_rampage:OnIntervalThink()
        local parent = self:GetParent()

        if parent and parent:GetHealthPercent() > self.max_hp then
            parent:SetHealth(parent:GetMaxHealth() * self.max_hp * 0.01)
        end
    end
end
