
modifier_hard_mode_boss = class({})

function modifier_hard_mode_boss:IsBuff()
    return true
end

function modifier_hard_mode_boss:IsHidden()
    return false
end

function modifier_hard_mode_boss:GetTexture()
    return "custom_avatar_debuff"
end

function modifier_hard_mode_boss:IsPurgable()
    return false
end

function modifier_hard_mode_boss:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
	return funcs
end

function modifier_hard_mode_boss:GetModifierPercentageCooldown()
    return 10
end

function modifier_hard_mode_boss:GetModifierTotalPercentageManaRegen()
	return 0.5
end


function modifier_hard_mode_boss:OnCreated() 
	local parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage_body.vpcf", PATTACH_POINT_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.particle,2,self:GetParent(),PATTACH_CENTER_FOLLOW,"attach_hitloc",self:GetParent():GetAbsOrigin(), true)
	
end

function modifier_hard_mode_boss:OnDestroy() 
	ParticleManager:DestroyParticle(self.particle, false)
	ParticleManager:ReleaseParticleIndex(self.particle)
end