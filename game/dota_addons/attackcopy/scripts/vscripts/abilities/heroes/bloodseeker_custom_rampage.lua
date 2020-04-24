


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
		self.parent = self:GetParent()
        local ability = self:GetAbility()
        self.max_hp = ability:GetSpecialValueFor("max_hp")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		
        self:StartIntervalThink(0.15)
    end
	function modifier_bloodseeker_custom_rampage:OnDestroy()
        ParticleManager:DestroyParticle(self.particle, false)
    end


    function modifier_bloodseeker_custom_rampage:OnIntervalThink()
        if self.parent and (self.parent:GetHealth() / self.parent:GetMaxHealth() * 100) > self.max_hp then
            self.parent:SetHealth(self.parent:GetMaxHealth() * self.max_hp * 0.01)
        end
    end
end
