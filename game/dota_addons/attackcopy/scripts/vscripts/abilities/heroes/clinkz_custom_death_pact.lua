require("lib/timers")



clinkz_custom_death_pact = class({})


    function clinkz_custom_death_pact:OnSpellStart()
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local duration = self:GetSpecialValueFor("duration")

		local damage = target:GetMaxHealth() * self:GetSpecialValueFor("damage_pct") * 0.01
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = self,
			damage_type = self:GetAbilityDamageType(),
			damage = damage
		})
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		caster:AddNewModifier(caster, self, "modifier_clinkz_custom_death_pact", {duration = self:GetSpecialValueFor("duration"), damage = damage})
		caster:EmitSound("Hero_Clinkz.DeathPact")
		
    end




LinkLuaModifier("modifier_clinkz_custom_death_pact", "abilities/heroes/clinkz_custom_death_pact.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_death_pact = class({})

function modifier_clinkz_custom_death_pact:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_death_pact_buff.vpcf"
end

function modifier_clinkz_custom_death_pact:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_clinkz_custom_death_pact:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
	}
	return funcs
end

function modifier_clinkz_custom_death_pact:OnCreated(keys)
    if not IsServer() then return end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
    self.damage = ability:GetSpecialValueFor("damage_gain_pct")
    self.health = ability:GetSpecialValueFor("health_gain_pct")
	local talent = caster:FindAbilityByName("special_bonus_unique_clinkz_8")
	if talent and talent:GetLevel() > 0 then
		self.damage = self.damage + talent:GetSpecialValueFor("value2")
		self.health = self.health + talent:GetSpecialValueFor("value")
	end
	self.damage = self.damage * keys.damage * 0.01
    self.health = self.health * keys.damage * 0.01
    self:SetHasCustomTransmitterData(true)
	caster:SetHealth(caster:GetHealth() + self.damage)
end

function modifier_clinkz_custom_death_pact:AddCustomTransmitterData( )
    return
    {
        damage = self.damage,
        health = self.health
    }
end

function modifier_clinkz_custom_death_pact:HandleCustomTransmitterData( data )
    self.damage = data.damage
    self.health = data.health
end

function modifier_clinkz_custom_death_pact:GetModifierPreAttack_BonusDamage()
    return self.damage
end
function modifier_clinkz_custom_death_pact:GetModifierHealthBonus()
    return self.health
end
function modifier_clinkz_custom_death_pact:GetDisableHealing()
    return 1
end