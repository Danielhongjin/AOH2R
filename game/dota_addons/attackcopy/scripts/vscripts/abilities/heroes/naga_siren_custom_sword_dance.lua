
naga_siren_custom_sword_dance = class({})


function naga_siren_custom_sword_dance:OnSpellStart()
    local caster = self:GetCaster()
	local units = Entities:FindAllByName(caster:GetName())
    local scepter = caster:HasScepter()
    EmitSoundOn("Hero_NagaSiren.Ensnare.Target", caster)
    EmitSoundOn("Hero_NagaSiren.Ensnare.Target", caster)
    for _, unit in ipairs(units) do
        if unit:IsAlive() then
            local modifier = unit:AddNewModifier(caster, self, "modifier_naga_siren_custom_sword_dance", {duration = self:GetSpecialValueFor("duration")})
            if scepter == true then
                modifier:SetStackCount(self:GetSpecialValueFor("scepter_initial_stacks"))
            else  
                modifier:SetStackCount(self:GetSpecialValueFor("initial_stacks"))
            end
        end
    end
end

LinkLuaModifier("modifier_naga_siren_custom_sword_dance", "abilities/heroes/naga_siren_custom_sword_dance.lua", LUA_MODIFIER_MOTION_NONE)
modifier_naga_siren_custom_sword_dance = class({})

function modifier_naga_siren_custom_sword_dance:IsHidden()
	return false
end

function modifier_naga_siren_custom_sword_dance:IsPurgable()
	return false
end

function modifier_naga_siren_custom_sword_dance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_naga_siren_custom_sword_dance:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resist_bonus")
end

function modifier_naga_siren_custom_sword_dance:GetModifierDamageOutgoing_Percentage()
	return self:GetStackCount() 
end

function modifier_naga_siren_custom_sword_dance:GetModifierMoveSpeedBonus_Percentage()
	return 10
end

function modifier_naga_siren_custom_sword_dance:GetModifierTotal_ConstantBlock()
	return self:GetParent():GetAverageTrueAttackDamage(self:GetParent()) * 0.25
end

if IsServer() then
    function modifier_naga_siren_custom_sword_dance:OnCreated()
        self.mult = 1 + self:GetAbility():GetSpecialValueFor("damage_multiplier") * 0.01
        self.particle = ParticleManager:CreateParticle("particles/econ/items/arc_warden/arc_warden_ti9_immortal/arc_warden_ti9_wraith_distortion.vpcf", PATTACH_POINT, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self.particle2 = ParticleManager:CreateParticle("particles/custom/naga_siren_sword_dance.vpcf", PATTACH_POINT, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.particle2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        EmitSoundOn("DOTA_Item.Radiance.Target.Loop", self:GetParent())
    end
    
    function modifier_naga_siren_custom_sword_dance:OnDestroy()
        ParticleManager:DestroyParticle(self.particle,  false)
        ParticleManager:DestroyParticle(self.particle2,  false)
        StopSoundOn("DOTA_Item.Radiance.Target.Loop", self:GetParent())
    end
    
    function modifier_naga_siren_custom_sword_dance:OnAttackLanded(keys)
        local parent = self:GetParent()
        if keys.attacker == parent or keys.target == parent then
            self:SetStackCount(math.ceil(self:GetStackCount() * self.mult))
        end  
    end
end