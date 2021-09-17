require("lib/popup")
LinkLuaModifier("modifier_target_delay", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)

skill_transfusion = class({})


function skill_transfusion:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:EmitSound("Hero_Terrorblade.Sunder.Cast")
	local value = caster:GetHealth() * (self:GetSpecialValueFor("health_pct") * 0.01)
	local fx = ParticleManager:CreateParticle("particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(
		fx,
		1,
		caster,
		PATTACH_POINT,
		"attach_hitloc",
		caster:GetAbsOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		fx,
		0,
		target,
		PATTACH_POINT,
		"attach_hitloc",
		target:GetAbsOrigin(), -- unknown
		true -- unknown, true
	)
	if target:GetTeam() == caster:GetTeam() then
		if target:GetHealthPercent() < caster:GetHealthPercent() then
			local total = ((caster:GetHealth() / caster:GetMaxHealth()) + (target:GetHealth() / target:GetMaxHealth())) / 2
			local bias = self:GetSpecialValueFor("friendly_bias") * 0.01
			print(total)
			target:Heal(target:GetMaxHealth() * ((total * (1 + bias)) - (target:GetHealth() / target:GetMaxHealth())), self)
			ParticleManager:SetParticleControl(fx, 15, Vector(0, 255, 0))
			create_popup({
				target = self.target,
				value = value,
				color = Vector(0, 255, 0),
				type = "heal",
			})	
			caster:ModifyHealth(caster:GetMaxHealth() * (total * (1 - bias)), self, false, 0)
		end
	else
		ParticleManager:SetParticleControl(fx, 15, Vector(255, 0, 0))
		ApplyDamage({
			attacker = caster,
			victim = target,
			ability = self,
			damage_type = self:GetAbilityDamageType(),
			damage = value
		})
		caster:ModifyHealth(caster:GetHealth() - value, self, false, 0)
		create_popup({
			target = target,
			value = value,
			color = Vector(100, 95, 237),
			type = "spell",
			pos = 6
		})
	end
	
	EmitSoundOn("Hero_Terrorblade.Sunder.Target", target)
end
