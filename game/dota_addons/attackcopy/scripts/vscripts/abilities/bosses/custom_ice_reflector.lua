function ice_reflector_activate(event)
	local caster = event.caster
	local ability = event.ability
	local threshold = ability:GetLevelSpecialValueFor("threshold", (ability:GetLevel() -1)) * 0.01
	local cooldown = ability:GetCooldown(ability:GetLevel())
	local health = caster:GetHealth() / caster:GetMaxHealth()
	if health < threshold and ability:GetCooldownTimeRemaining() == 0 then
		ability:StartCooldown(cooldown)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_ice_reflector_initial", {})
		EmitSoundOn("Hero_Lich.FrostArmor", caster)
	end
end

function ice_reflector_damage_taken(keys)
	local caster = keys.caster
	local target = keys.attacker
	local damage = keys.DamageTaken
	
	if not target:IsMagicImmune() then
		local damage_table = 
		{
			attacker = caster,
			victim = target,
			ability = keys.ability,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
			damage = damage
		}
		ApplyDamage(damage_table)
	end
end

function FrostArmorParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = "particles/units/heroes/hero_lich/lich_frost_armor.vpcf"

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function()
		target.FrostArmorParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.FrostArmorParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.FrostArmorParticle, 1, Vector(1,0,0))

		ParticleManager:SetParticleControlEnt(target.FrostArmorParticle, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
	end)
end

function EndFrostArmorParticle( event )
	local target = event.target
	ParticleManager:DestroyParticle(target.FrostArmorParticle,false)
end