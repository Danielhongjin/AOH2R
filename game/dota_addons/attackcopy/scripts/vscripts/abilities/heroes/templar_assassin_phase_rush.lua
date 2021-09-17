
templar_assassin_phase_rush = class({})


function templar_assassin_phase_rush:OnToggle()
	local caster = self:GetCaster()
    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, "modifier_templar_assassin_phase_rush_toggle", {})
    else
        caster:RemoveModifierByName("modifier_templar_assassin_phase_rush_toggle")
    end
end

function templar_assassin_phase_rush:GetIntrinsicModifierName()
    return "modifier_templar_assassin_phase_rush"
end

function templar_assassin_phase_rush:OnUpgrade()
	if self:GetLevel() > 0 then
		self:GetCaster():FindModifierByName("modifier_templar_assassin_phase_rush"):ForceRefresh()
	end
end

LinkLuaModifier("modifier_templar_assassin_phase_rush_toggle", "abilities/heroes/templar_assassin_phase_rush.lua", LUA_MODIFIER_MOTION_NONE)
modifier_templar_assassin_phase_rush_toggle = class({})

function modifier_templar_assassin_phase_rush_toggle:IsHidden()
	return false
end

function modifier_templar_assassin_phase_rush_toggle:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
    }
end

function modifier_templar_assassin_phase_rush_toggle:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_templar_assassin_phase_rush_toggle:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_templar_assassin_phase_rush_toggle:GetActivityTranslationModifiers()
  return "haste"
end

function modifier_templar_assassin_phase_rush_toggle:GetModifierEvasion_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end

function modifier_templar_assassin_phase_rush_toggle:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_movespeed")
end

function modifier_templar_assassin_phase_rush_toggle:GetModifierMagicalResistanceBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_resist")
end

function modifier_templar_assassin_phase_rush_toggle:GetStatusEffectName()
    return "particles/custom/status_effect_phase_rush.vpcf"
end

function modifier_templar_assassin_phase_rush_toggle:StatusEffectPriority()
    return 900
end

if IsServer() then
	function modifier_templar_assassin_phase_rush_toggle:OnCreated()
		self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.parent:EmitSound("Hero_TemplarAssassin.Trap")
        self.health_degen = self:GetAbility():GetSpecialValueFor("health_degen") * 0.01 * 0.2
        self.mana_degen = self:GetAbility():GetSpecialValueFor("mana_degen") * 0.01 * 0.2
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_trap_start_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
        EmitSoundOn("DOTA_Item.Radiance.Target.Loop", self.parent)
		self:StartIntervalThink(0.2)
	end

	function modifier_templar_assassin_phase_rush_toggle:OnIntervalThink()
		if self.parent:GetManaPercent() < 5 or self.parent:GetHealthPercent() < 5 then
			self.ability:ToggleAbility()
		end
        self.parent:SpendMana(self.mana_degen * self.parent:GetMaxMana(), self.ability)
        self.parent:ModifyHealth(self.parent:GetHealth() - (self.parent:GetMaxHealth() * self.health_degen), self.ability, false, 0)
	end
    
    function modifier_templar_assassin_phase_rush_toggle:OnDestroy()
        StopSoundOn("DOTA_Item.Radiance.Target.Loop", self:GetParent())
    end
end

LinkLuaModifier("modifier_templar_assassin_phase_rush", "abilities/heroes/templar_assassin_phase_rush.lua", LUA_MODIFIER_MOTION_NONE)
modifier_templar_assassin_phase_rush = class({})

function modifier_templar_assassin_phase_rush:IsHidden()
	return false
end

function modifier_templar_assassin_phase_rush:RemoveOnDeath()
	return false
end

function modifier_templar_assassin_phase_rush:IsPurgable()
	return false
end

function modifier_templar_assassin_phase_rush:RemoveOnDeath()
	return false
end

function modifier_templar_assassin_phase_rush:GetTexture()
	return "templar_assassin_self_trap"
end


function modifier_templar_assassin_phase_rush:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end


function modifier_templar_assassin_phase_rush:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetStackCount()
end

if IsServer() then
    function modifier_templar_assassin_phase_rush:OnCreated()
        self.parent = self:GetParent()
        self:SetStackCount(0)
    end
    
    function modifier_templar_assassin_phase_rush:OnRefresh()
        self.pos = self.parent:GetAbsOrigin()
        local interval = self:GetAbility():GetSpecialValueFor("interval")
        self.ratio = self:GetAbility():GetSpecialValueFor("movement_ratio") * interval
        self:StartIntervalThink(interval)
    end
    
    function modifier_templar_assassin_phase_rush:OnIntervalThink()
        local pos = self.parent:GetAbsOrigin()
        local distance = (self.pos - pos):Length2D() / self.ratio
        if distance > 40 then
            distance = 40
        end
        local stacks = (self:GetStackCount() * 0.9) - 2 + distance
        if stacks < 0 then
            stacks = 0
        end
        self:SetStackCount(stacks)
        self.pos = pos
    end

end