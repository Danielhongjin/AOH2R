require("lib/popup")

skill_trident = class({})

function skill_trident:OnSpellStart()
	local caster = self:GetCaster()
	local origin = caster:GetOrigin()
	local point = self:GetCursorPosition()

	local projectile_name = "particles/custom/skill_trident.vpcf"
	local projectile_speed = self:GetSpecialValueFor("speed")
	local projectile_distance = self:GetSpecialValueFor("range") + caster:GetCastRangeBonus()
	
	local projectile_start_radius = self:GetSpecialValueFor("width")
	local projectile_vision = self:GetSpecialValueFor("vision")
	local damage = self:GetSpecialValueFor("base_damage")
	
	local projectile_direction = (Vector(point.x-origin.x, point.y-origin.y,0)):Normalized()
	self.has_hit = false
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin() + Vector(0, 0, 150),
		
	    bDeleteOnHit = true,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
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
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
function skill_trident:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	local caster = self:GetCaster()
	if hTarget==nil or hTarget == caster then return end
	FindClearSpaceForUnit(caster, hTarget:GetAbsOrigin(), false)
	if hTarget:GetTeam() ~= caster:GetTeam() then
		local fx = ParticleManager:CreateParticle("particles/custom/skill_trident_hit.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(
			fx,
			0,
			hTarget,
			PATTACH_POINT,
			"attach_hitloc",
			hTarget:GetAbsOrigin(), -- unknown
			true -- unknown, true
		)
		caster:PerformAttack(hTarget, true, true, true, true, true, false, false)
		if hTarget:HasModifier("modifier_anim") then
			caster:PerformAttack(hTarget, true, true, true, true, true, false, false) 
			caster:PerformAttack(hTarget, true, true, true, true, true, false, false) 
			local fx = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_weapon_style2_blur_critical.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(
				fx,
				0,
				hTarget,
				PATTACH_POINT,
				"attach_hitloc",
				hTarget:GetAbsOrigin(), -- unknown
				true -- unknown, true
			)
		end
		
		ApplyDamage(damageTable)

		AddFOWViewer(self:GetCaster():GetTeamNumber(), vLocation, 500, 3, false)
		local sound_cast = "Hero_TemplarAssassin.Trap.Explode"
		EmitSoundOn( sound_cast, hTarget )
	end
	return true
	
end