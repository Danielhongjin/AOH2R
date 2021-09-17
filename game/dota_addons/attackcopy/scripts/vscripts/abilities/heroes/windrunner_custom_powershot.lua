
windrunner_custom_powershot = class({})
LinkLuaModifier( "modifier_windrunner_custom_powershot", "lua_abilities/windrunner_custom_powershot/modifier_windrunner_custom_powershot", LUA_MODIFIER_MOTION_NONE )

function windrunner_custom_powershot:GetChannelTime()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_skill_flashcaster") then
		return self:GetSpecialValueFor("channel_time") * 0.6
	end
	return self:GetSpecialValueFor("channel_time")
end

--------------------------------------------------------------------------------
-- Ability Start
function windrunner_custom_powershot:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- Play effects
	local sound_cast = "Ability.PowershotPull"
	EmitSoundOnLocationForAllies( caster:GetOrigin(), sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Ability Channeling
function windrunner_custom_powershot:OnChannelFinish( bInterrupted )
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime())/self:GetChannelTime()

	-- load data
	local damage = self:GetSpecialValueFor( "powershot_damage" )
	local damage_base_pct = self:GetSpecialValueFor( "damage_base_pct" ) * 0.01
	local reduction = (100 - self:GetSpecialValueFor("damage_reduction")) * 0.01
	local vision_radius = self:GetSpecialValueFor( "vision_radius" )
	
	local projectile_name = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
	local projectile_speed = self:GetSpecialValueFor( "arrow_speed" )
	
	local projectile_distance = self:GetSpecialValueFor( "arrow_range" )
	local projectile_radius = self:GetSpecialValueFor( "arrow_width" )
	local projectile_direction = point-caster:GetOrigin()
	local talent = caster:FindAbilityByName("special_bonus_unique_windranger_3")
	if projectile_direction.x == 0 and projectile_direction.y == 0 then
		projectile_direction = caster:GetForwardVector()
	end
	if talent and talent:GetLevel() > 0 then
		damage = damage + talent:GetSpecialValueFor("value")
	end
	
	projectile_direction.z = 0
	projectile_direction = projectile_direction:Normalized()

	-- create projectile
	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius = projectile_radius,
		vVelocity = projectile_direction * projectile_speed,
	
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber(),
		
	}
	
	local projectile = ProjectileManager:CreateLinearProjectile(info)

	-- register projectile data
	self.projectiles[projectile] = {}
	self.projectiles[projectile].damage = damage * damage_base_pct + damage * channel_pct * (1 - damage_base_pct)
	self.projectiles[projectile].reduction = reduction

	-- Play effects
	local sound_cast = "Ability.Powershot"
	EmitSoundOn( sound_cast, caster )
end

--------------------------------------------------------------------------------
-- Projectile
-- projectile data table
windrunner_custom_powershot.projectiles = {}

function windrunner_custom_powershot:OnProjectileHitHandle( target, location, handle )
	if not target then
		-- unregister projectile
		self.projectiles[handle] = nil

		-- create Vision
		local vision_radius = self:GetSpecialValueFor( "vision_radius" )
		local vision_duration = self:GetSpecialValueFor( "vision_duration" )
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, vision_radius, vision_duration, false )

		return
	end

	-- get data
	local data = self.projectiles[handle]
	local damage = data.damage
	if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
		damage = damage * (1.0 + ((target:GetHealthDeficit() / target:GetMaxHealth())) / 1.5)
	end
	-- damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
	}
	ApplyDamage(damageTable)

	-- reduce damage
	data.damage = data.damage * data.reduction

	-- Play effects
	local sound_cast = "Hero_Windrunner.PowershotDamage"
	EmitSoundOn( sound_cast, target )
end

function windrunner_custom_powershot:OnProjectileThink( location )
	-- destroy trees
	local tree_width = self:GetSpecialValueFor( "tree_width" )
	GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
end