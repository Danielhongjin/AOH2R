skywrath_mage_custom_concussive_shot = class({})


--------------------------------------------------------------------------------
-- Ability Start
function skywrath_mage_custom_concussive_shot:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()

	-- load data
	local search_radius = self:GetSpecialValueFor( "launch_radius" )

	local projectile_name = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "speed" )
	local projectile_vision = self:GetSpecialValueFor( "shot_vision" )

	-- search enemy heroes
	local enemies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		search_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
		FIND_CLOSEST,	-- int, order filter
		false	-- bool, can grow cache
	)
	-- prioritize hero, then creep
	local target = nil
	for _,enemy in pairs(enemies) do
		if enemy:IsHero() then
			target = enemy
			break
		end
	end
	if not target then
		target = enemies[1]
	end

	-- if no one found, it's dud
	if not target then
		self:PlayEffects2()
		return
	end

	-- create projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = self,	
		
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		bDodgeable = true,                           -- Optional
	
		bVisibleToEnemies = true,                         -- Optional

		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber(),        -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)	

	-- play effects
	self:PlayEffects1( target )

	-- scepter effects
	if caster:HasScepter() then
		local scepter_radius = self:GetSpecialValueFor( "scepter_radius" )
		
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			target:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			scepter_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local target_2 = nil
		-- prioritize hero
		target_2 = enemies[1]		-- could be nil
		if target_2==target then
			target_2 = enemies[2]	-- could be nil
		end


		-- check secondary target
		if target_2 and (not target_2:IsMagicImmune()) then
			-- launch projectile
			info.Target = target_2
			ProjectileManager:CreateTrackingProjectile(info)
			self:PlayEffects1( target_2 )
		end
	end
end
--------------------------------------------------------------------------------
-- Projectile
function skywrath_mage_custom_concussive_shot:OnProjectileHit( target, location )
	if not target then return end

	-- get data
	local radius = self:GetSpecialValueFor( "slow_radius" )
	local damage = self:GetSpecialValueFor( "damage" )
	local duration = self:GetSpecialValueFor( "slow_duration" )
	local creep_mult = self:GetSpecialValueFor( "creep_damage_pct" )
	local vision = self:GetSpecialValueFor( "shot_vision" )
	local vision_duration = self:GetSpecialValueFor( "vision_duration" )

	-- precache damage
	local damageTable = {
		-- victim = target,
		attacker = self:GetCaster(),
		-- damage = 500,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	-- ApplyDamage(damageTable)

	-- find units nearby
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		target:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- damage
		damageTable.victim = enemy
		damageTable.damage = damage
		if enemy:IsCreep() then
			damageTable.damage = damage * (creep_mult/100)
		end
		ApplyDamage( damageTable )

		-- slow
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self, -- ability source
			"modifier_skywrath_mage_custom_concussive_shot", -- modifier name
			{ duration = duration } -- kv
		)
	end

	-- vision
	AddFOWViewer(
		self:GetCaster():GetTeamNumber(), --nTeamID
		target:GetOrigin(), --vLocation
		vision, --flRadius
		vision_duration, --flDuration
		false --bObstructedVision
	)

	-- play effects
	local sound_target = "Hero_SkywrathMage.ConcussiveShot.Target"
	EmitSoundOn( sound_target, target )
end

--------------------------------------------------------------------------------
function skywrath_mage_custom_concussive_shot:PlayEffects1( target )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_cast.vpcf"
	local sound_cast = "Hero_SkywrathMage.ConcussiveShot.Cast"

	-- get data
	local projectile_speed = self:GetSpecialValueFor( "speed" )

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( projectile_speed, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end

function skywrath_mage_custom_concussive_shot:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_failure.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

LinkLuaModifier( "modifier_skywrath_mage_custom_concussive_shot", "abilities/heroes/skywrath_mage_custom_concussive_shot.lua", LUA_MODIFIER_MOTION_NONE )
modifier_skywrath_mage_custom_concussive_shot = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_skywrath_mage_custom_concussive_shot:IsHidden()
	return false
end

function modifier_skywrath_mage_custom_concussive_shot:IsDebuff()
	return true
end

function modifier_skywrath_mage_custom_concussive_shot:IsStunDebuff()
	return false
end

function modifier_skywrath_mage_custom_concussive_shot:IsPurgable()
	return true
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_skywrath_mage_custom_concussive_shot:OnCreated( kv )
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor( "movement_speed_pct" )
end

function modifier_skywrath_mage_custom_concussive_shot:OnRefresh( kv )
	-- references
	self.slow = -self:GetAbility():GetSpecialValueFor( "movement_speed_pct" )
end

function modifier_skywrath_mage_custom_concussive_shot:OnRemoved()
end

function modifier_skywrath_mage_custom_concussive_shot:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_skywrath_mage_custom_concussive_shot:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_skywrath_mage_custom_concussive_shot:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_skywrath_mage_custom_concussive_shot:GetEffectName()
	return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_slow_debuff.vpcf"
end

function modifier_skywrath_mage_custom_concussive_shot:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end


