
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
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_hard_mode_boss:GetModifierPercentageCooldown()
    return 20
end

function modifier_hard_mode_boss:GetModifierTotalPercentageManaRegen()
	return 1.0
end

function modifier_hard_mode_boss:GetModifierPhysicalArmorBonus()
	return 2
end

function modifier_hard_mode_boss:GetModifierMagicalResistanceBonus()
	return 5
end

function modifier_hard_mode_boss:OnCreated() 
	local parent = self:GetParent()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_rage_body.vpcf", PATTACH_POINT_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(particle, 2, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_hard_mode_boss:OnDestroy() 

end