
boss_juggernaut_instant_strike = class({})

function boss_juggernaut_instant_strike:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()

	local projectile_name = "particles/custom/phantom_assassin_stifling_dagger_custom.vpcf"
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_distance = self:GetSpecialValueFor("range")
	
	local projectile_start_radius = self:GetSpecialValueFor("width")
	local projectile_vision = self:GetSpecialValueFor("vision")
	local damage = self:GetSpecialValueFor("damage")
	
	local projectile_direction = (Vector(point.x-origin.x, point.y-origin.y,0)):Normalized()
	self.has_hit = false
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
	    fEndRadius = projectile_start_radius,
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
	local projectile = ProjectileManager:CreateLinearProjectile(info)
	local sound_cast = "Hero_TemplarAssassin.Trap"
	EmitSoundOn(sound_cast, caster)
end

--------------------------------------------------------------------------------
-- Projectile
function boss_juggernaut_instant_strike:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	if hTarget==nil then return end
	local caster = self:GetCaster()
	self.has_hit = true
	local damageTable = {
		victim = hTarget,
		attacker = caster,
		damage = extraData.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)
	local omnislash = caster:FindAbilityByName("boss_juggernaut_swift_slash")
	caster:SetCursorCastTarget(hTarget)
	omnislash:OnSpellStart()
	local spell = caster:FindAbilityByName("boss_juggernaut_instant_strike_wrapper")
	spell:EndCooldown()
	spell:StartCooldown(2)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false)
	local sound_cast = "Hero_TemplarAssassin.Trap.Explode"
	EmitSoundOn( sound_cast, hTarget )

	return true
end

