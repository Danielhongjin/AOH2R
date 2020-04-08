necrolyte_intelligence_supremacy = class({})


function necrolyte_intelligence_supremacy:GetIntrinsicModifierName()
    return "modifier_necrolyte_intelligence_supremacy"
end

LinkLuaModifier("modifier_necrolyte_intelligence_supremacy", "abilities/heroes/necrolyte_intelligence_supremacy.lua", LUA_MODIFIER_MOTION_NONE)
modifier_necrolyte_intelligence_supremacy = class({})


function modifier_necrolyte_intelligence_supremacy:IsHidden()
    return true
end

if IsServer() then
    function modifier_necrolyte_intelligence_supremacy:OnCreated(keys)
        local ability = self:GetAbility()
        self.radius = ability:GetSpecialValueFor("radius")
        self.target_type = ability:GetAbilityTargetType()
        self.target_team = ability:GetAbilityTargetTeam()
        self.target_flags = ability:GetAbilityTargetFlags()
    end

    function modifier_necrolyte_intelligence_supremacy:IsAura()
        return true
    end
	function modifier_necrolyte_intelligence_supremacy:IsPurgable()
		return false
	end
    function modifier_necrolyte_intelligence_supremacy:GetAuraRadius()
        return self.radius
    end
    function modifier_necrolyte_intelligence_supremacy:GetAuraSearchTeam()
        return self.target_team
    end


    function modifier_necrolyte_intelligence_supremacy:GetAuraSearchType()
        return self.target_type
    end


    function modifier_necrolyte_intelligence_supremacy:GetAuraSearchFlags()
        return self.target_flags
    end


    function modifier_necrolyte_intelligence_supremacy:GetModifierAura()
        return "modifier_necrolyte_intelligence_supremacy_debuff"
    end
end


LinkLuaModifier("modifier_necrolyte_intelligence_supremacy_debuff", "abilities/heroes/necrolyte_intelligence_supremacy.lua", LUA_MODIFIER_MOTION_NONE)
modifier_necrolyte_intelligence_supremacy_debuff = class({})

function modifier_necrolyte_intelligence_supremacy_debuff:IsDebuff()
    return true
end

function modifier_necrolyte_intelligence_supremacy_debuff:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end


if IsServer() then

	function modifier_necrolyte_intelligence_supremacy_debuff:GetModifierConstantHealthRegen()
		return self.regen
	end
    function modifier_necrolyte_intelligence_supremacy_debuff:OnCreated(keys)
        self.ability = self:GetAbility()
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		local talent = self.caster:FindAbilityByName("special_bonus_unique_necrophos_2")
		self.int_mult = self.ability:GetSpecialValueFor("int_multiplier")
		if talent and talent:GetLevel() > 0 then
			self.int_mult = self.int_mult + talent:GetSpecialValueFor("value")
		end
		local talent2 = self.caster:FindAbilityByName("special_bonus_unique_necrophos_5")
		if talent2 and talent2:GetLevel() > 0 then
			self.regen = -(talent2:GetSpecialValueFor("value"))
		end
		
		ApplyDamage({
			attacker = self.caster,
			victim = self.parent,
			ability = self.ability,
			damage_type = self.ability:GetAbilityDamageType(),
			damage = self.damage
		})
        self.tick_interval = self.ability:GetSpecialValueFor("interval")
		self.int_mult = self.int_mult * self.tick_interval
        self.damage = self.caster:GetIntellect() * self.int_mult
        if self.parent then
            self:StartIntervalThink(self.tick_interval)
        end
    end

	
    function modifier_necrolyte_intelligence_supremacy_debuff:OnIntervalThink()
		self.damage = self.caster:GetIntellect() * self.int_mult
        ApplyDamage({
			attacker = self.caster,
			victim = self.parent,
			ability = self.ability,
			damage_type = self.ability:GetAbilityDamageType(),
			damage = self.damage
		})
    end
end