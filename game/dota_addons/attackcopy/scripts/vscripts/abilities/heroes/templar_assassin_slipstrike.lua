templar_assassin_slipstrike = class({})

function templar_assassin_slipstrike:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()

	local projectile_name = "particles/custom/templar_assassin_slipstrike.vpcf"
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_distance = self:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
	local projectile_start_radius = self:GetSpecialValueFor("width")
	local projectile_vision = self:GetSpecialValueFor("vision")
	local damage = self:GetSpecialValueFor("base_damage")

	local projectile_direction = (Vector(point.x-origin.x, point.y-origin.y,0)):Normalized()

	-- logic
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin() + Vector(0, 0, 150),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_start_radius,
	    fEndRadius =projectile_end_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		iVisionTeamNumber = caster:GetTeamNumber(),

		ExtraData = {
			originX = origin.x,
			originY = origin.y,
			originZ = origin.z,

			max_distance = max_distance,
			min_stun = min_stun,
			max_stun = max_stun,

			damage = damage,
		}
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- Effects
	local sound_cast = "Hero_TemplarAssassin.Trap"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function templar_assassin_slipstrike:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	if hTarget==nil then return end
	local caster = self:GetCaster()
	
	local damageTable = {
		victim = hTarget,
		attacker = caster,
		damage = extraData.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	damageTable.damage = damageTable.damage + (caster:GetAverageTrueAttackDamage(caster) * self:GetSpecialValueFor("attack_damage") * 0.01)
	if hTarget:HasModifier("modifier_anim") then
		local bonus_damage = self:GetSpecialValueFor("bonus_damage") * 0.01
		damageTable.damage = damageTable.damage * bonus_damage
		if caster:HasScepter() then
			if not caster:HasModifier("modifier_templar_assassin_slipstrike") then
				local modifier = caster:AddNewModifier(caster, self, "modifier_templar_assassin_slipstrike", {duration = -1})
				modifier:SetStackCount(self:GetSpecialValueFor("bonus_agi"))
			else
				local modifier = caster:FindModifierByName("modifier_templar_assassin_slipstrike")
				modifier:SetStackCount(self:GetSpecialValueFor("bonus_agi") + modifier:GetStackCount())
			end
		end
		local fx = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_trap_explode_butterfly.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, hTarget:GetAbsOrigin())
		ParticleManager:SetParticleControl(fx, 3, hTarget:GetAbsOrigin())
	else
		local fx = ParticleManager:CreateParticle("particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(fx, 0, hTarget:GetAbsOrigin())
	end
	
	ApplyDamage(damageTable)

	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false)
	local sound_cast = "Hero_TemplarAssassin.Trap.Explode"
	EmitSoundOn( sound_cast, hTarget )

	return true
end


LinkLuaModifier("modifier_templar_assassin_slipstrike", "abilities/heroes/templar_assassin_slipstrike.lua", LUA_MODIFIER_MOTION_NONE)
modifier_templar_assassin_slipstrike = class({})

function modifier_templar_assassin_slipstrike:IsHidden()
    return true
end

function modifier_templar_assassin_slipstrike:IsPurgable()
	return false
end

function modifier_templar_assassin_slipstrike:RemoveOnDeath()
	return false
end

function modifier_templar_assassin_slipstrike:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_templar_assassin_slipstrike:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end


function modifier_templar_assassin_slipstrike:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end
