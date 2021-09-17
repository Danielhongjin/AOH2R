	-- Created by Elfansoer
--[[
Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
mars_custom_spear = class({})
LinkLuaModifier( "modifier_mars_spear_of_mars_lua", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mars_spear_of_mars_lua_checker", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mars_spear_of_mars_lua_debuff", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_spear_of_mars_linger_thinker", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_mars_spear_of_mars_debuff", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_stunned_lua", "modifiers/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mars_talent", "abilities/heroes/mars_spear_of_mars_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Ability Start

 function mars_custom_spear:GetCooldown(iLevel)
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_mars_talent") then
		return self.BaseClass.GetCooldown(self, iLevel) - self:GetSpecialValueFor("talent")
	end
	return self.BaseClass.GetCooldown(self, iLevel)
end

function mars_custom_spear:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
    
	-- load data
	local projectile_name = "particles/units/heroes/hero_mars/mars_spear.vpcf"
	local projectile_distance = self:GetSpecialValueFor("spear_range") + caster:GetCastRangeBonus()
	local projectile_speed = self:GetSpecialValueFor("spear_speed")
	local projectile_radius = self:GetSpecialValueFor("spear_width")
	local projectile_vision = self:GetSpecialValueFor("spear_vision")
    self.shard = false
    if self:GetCaster():HasModifier("modifier_item_aghanims_shard") then
        self.shard = true
        self.linger_time = self:GetSpecialValueFor("shard_duration")
        projectile_distance = projectile_distance + self:GetSpecialValueFor("spear_bonus_range")
    end
    
	-- calculate direction
	local direction = point - caster:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetOrigin(),
		
	    bDeleteOnHit = false,
	    
	    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    
	    EffectName = projectile_name,
	    fDistance = projectile_distance,
	    fStartRadius = projectile_radius,
	    fEndRadius =projectile_radius,
		vVelocity = direction * projectile_speed,
	
		bHasFrontalCone = false,
		bReplaceExisting = false,
		-- fExpireTime = GameRules:GetGameTime() + 10.0,
		
		bProvidesVision = true,
		iVisionRadius = projectile_vision,
		fVisionDuration = 10,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)

	-- play effects
	local sound_cast = "Hero_Mars.Spear.Cast"
	EmitSoundOn( sound_cast, caster )
	local sound_cast = "Hero_Mars.Spear"
	EmitSoundOn( sound_cast, caster )
	local talent = caster:FindAbilityByName("special_bonus_unique_mars_spear_cooldown")
	if talent and talent:GetLevel() > 0 then
		local modifier = caster:AddNewModifier(caster, self, "modifier_mars_talent", {})
	end
    
end

--------------------------------------------------------------------------------
-- Projectile
-- projectile management
--[[
Fields:
- location
- direction
- init_pos
- unit
- modifier
- active
]]
local mars_projectiles = {}
function mars_projectiles:Init( projectileID )
	self[projectileID] = {}

	-- set location
	self[projectileID].location = ProjectileManager:GetLinearProjectileLocation( projectileID )
	self[projectileID].init_pos = self[projectileID].location
    self[projectileID].flip = 0

	-- set direction
	local direction = ProjectileManager:GetLinearProjectileVelocity( projectileID )
	direction.z = 0
	direction = direction:Normalized()
	self[projectileID].direction = direction
end

function mars_projectiles:Destroy( projectileID )
	self[projectileID] = nil
end
mars_custom_spear.projectiles = mars_projectiles

-- projectile hit
function mars_custom_spear:OnProjectileHitHandle( target, location, iProjectileHandle )
	-- init in case it isn't initialized from below (if projectile launched very close to target)
	if not self.projectiles[iProjectileHandle] then
		self.projectiles:Init( iProjectileHandle )
	end
	if not target then
		-- add viewer
		local projectile_vision = self:GetSpecialValueFor("spear_vision")
		AddFOWViewer( self:GetCaster():GetTeamNumber(), location, projectile_vision, 1, false)

		-- destroy data
		self.projectiles:Destroy( iProjectileHandle )
		return
	end

	-- get stun and damage
	local stun = self:GetSpecialValueFor("stun_duration")
	self.damage = self:GetSpecialValueFor("damage")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_mars_spear_bonus_damage")

    if talent and talent:GetLevel() > 0 then
        self.damage = self.damage + talent:GetSpecialValueFor("value")
    end

	-- apply damage
	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = self.damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self, --Optional.
		damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
	}
	ApplyDamage(damageTable)

	-- check if it has skewered a unit, or target is not a hero


	-- add modifier to skewered unit
	local modifier = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_mars_spear_of_mars_lua", -- modifier name
		{
			projectile = iProjectileHandle,
		} -- kv
	)
	self.arenaChecker = target:AddNewModifier(
		self:GetCaster(), -- player source
		self, -- ability source
		"modifier_mars_spear_of_mars_lua_checker", -- modifier name
		{
		duration = 2
		} -- kv
	)
	self.projectiles[iProjectileHandle].unit = target
	self.projectiles[iProjectileHandle].modifier = modifier
	self.projectiles[iProjectileHandle].active = false

	-- play effects
	local sound_cast = "Hero_Mars.Spear.Target"
	EmitSoundOn( sound_cast, target )
end

-- projectile think
function mars_custom_spear:OnProjectileThinkHandle( iProjectileHandle )
	-- init for the first time
	if not self.projectiles[iProjectileHandle] then
		self.projectiles:Init( iProjectileHandle )
	end

	local data = self.projectiles[iProjectileHandle]

	-- init data
	local tree_radius = 120
	local wall_radius = 50
	local building_radius = 30
	local blocker_radius = 70

	-- save location
	local location = ProjectileManager:GetLinearProjectileLocation( iProjectileHandle )
	data.location = location
    if self.shard then
        data.flip = data.flip + 1
        if data.flip > 1 then
            CreateModifierThinker(self:GetCaster(), self, "modifier_mars_spear_of_mars_linger_thinker", { duration = self.linger_time }, GetGroundPosition( location, self:GetCaster() ), self:GetCaster():GetTeamNumber(), false)
            data.flip = 0
        end
    end
	-- check skewered unit, and dragged (caught unit not necessarily dragged)
	if not data.unit then return end
	if not data.active then
		-- check distance, mainly to avoid being pinned while behind the tree/cliffs
		local difference = (data.unit:GetOrigin()-data.init_pos):Length2D() - (location-data.init_pos):Length2D()
		if difference > 0 then return end
		data.active = true
	end


	-- search for blocker
	local thinkers = Entities:FindAllByClassnameWithin( "npc_dota_thinker", location, wall_radius )
	for _,thinker in pairs(thinkers) do
		if thinker:IsPhantomBlocker() then
			self:Pinned( iProjectileHandle )
			return
		end
	end

	-- search for high ground
	local base_loc = GetGroundPosition( location, data.unit )
    
	local search_loc = GetGroundPosition( base_loc + data.direction*wall_radius, data.unit )
	if search_loc.z - base_loc.z > 10 and (not GridNav:IsTraversable( search_loc )) then
		self:Pinned( iProjectileHandle )
		return
	end

	-- search for tree
	if GridNav:IsNearbyTree( location, tree_radius, false) then
        if self.shard then
            self:ShardTreePinned( iProjectileHandle )
            GridNav:DestroyTreesAroundPoint(location, tree_radius, false)
        else
            self:Pinned( iProjectileHandle )
            return
        end
		
	end
	
	if not data.unit:HasModifier("modifier_mars_spear_of_mars_lua_checker") and data.unit:IsAlive() then
		ApplyDamage({
			victim = data.unit,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self, --Optional.
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		})
		self:Pinned( iProjectileHandle )
		return
	end

	-- search for buildings
	local buildings = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		location,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		building_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_BUILDING,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #buildings>0 then
		-- pinned
		self:Pinned( iProjectileHandle )
		return
	end
    
end
function mars_custom_spear:ShardTreePinned( iProjectileHandle )
    local data = self.projectiles[iProjectileHandle]
    local duration = self:GetSpecialValueFor("stun_duration")
    self:GetCaster():PerformAttack(data.unit, true, true, true, true, true, false, true) 
    AddFOWViewer(self:GetCaster():GetTeamNumber(), data.unit:GetOrigin(), 100, 2, false)
    data.unit:AddNewModifier(
	self:GetCaster(), -- player source
	self, -- ability source
	"modifier_mars_spear_of_mars_lua_debuff", -- modifier name
	{
		duration = duration,
		projectile = iProjectileHandle,
	}
	)
    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_base_attack_impact_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControlEnt( nFXIndex, 0, data.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", data.unit:GetAbsOrigin(), true )
    ParticleManager:ReleaseParticleIndex( nFXIndex )
    EmitSoundOn("Hero_Mars.Spear.Root", data.unit )
end
function mars_custom_spear:Pinned( iProjectileHandle )
	local data = self.projectiles[iProjectileHandle]
	local duration = self:GetSpecialValueFor("stun_duration")
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_mars_spear_stun_duration")

    if talent and talent:GetLevel() > 0 then
        duration = duration + talent:GetSpecialValueFor("value")
    end
	local projectile_vision = self:GetSpecialValueFor("spear_vision")

	AddFOWViewer( self:GetCaster():GetTeamNumber(), data.unit:GetOrigin(), projectile_vision, duration, false)
	
    data.unit:AddNewModifier(
	self:GetCaster(), -- player source
	self, -- ability source
	"modifier_mars_spear_of_mars_lua_debuff", -- modifier name
	{
		duration = duration,
		projectile = iProjectileHandle,
	}
	)
    
	ProjectileManager:DestroyLinearProjectile( iProjectileHandle )
	if data.modifier then
		if not data.modifier:IsNull() then
			data.modifier:Destroy()
            FindClearSpaceForUnit(data.unit, GetGroundPosition( data.location, data.unit), false)
		end
	end
	-- play effects
	self:PlayEffects( iProjectileHandle, duration )

	-- delete data
	self.projectiles:Destroy( iProjectileHandle )
end
--------------------------------------------------------------------------------
function mars_custom_spear:PlayEffects( projID, duration )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_mars/mars_spear_impact.vpcf"
	local sound_cast = "Hero_Mars.Spear.Root"

	-- Get Data
	local data = self.projectiles[projID]
	local delta = 50
	local location = GetGroundPosition( data.location, data.unit ) + data.direction*delta

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, location )
	ParticleManager:SetParticleControl( effect_cast, 1, data.direction*1000 )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControlForward( effect_cast, 0, data.direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, data.unit )
end

modifier_mars_talent = class({})
function modifier_mars_talent:IsHidden()
	return true
end

function modifier_mars_talent:IsPurgable()
	return true
end

modifier_mars_spear_of_mars_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mars_spear_of_mars_lua:IsHidden()
	return false
end

function modifier_mars_spear_of_mars_lua:IsDebuff()
	return true
end

function modifier_mars_spear_of_mars_lua:IsStunDebuff()
	return true
end

function modifier_mars_spear_of_mars_lua:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_mars_spear_of_mars_lua:OnCreated( kv )
	-- references
	self.ability = self:GetAbility()

	if IsServer() then
		self.projectile = kv.projectile

		-- face towards
		self:GetParent():SetForwardVector( -self:GetAbility().projectiles[kv.projectile].direction )
		self:GetParent():FaceTowards( self.ability.projectiles[self.projectile].init_pos )

		-- try apply
		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function modifier_mars_spear_of_mars_lua:OnRefresh( kv )
	
end

function modifier_mars_spear_of_mars_lua:OnRemoved()
	if not IsServer() then return end
	-- Compulsory interrupt
	self:GetParent():InterruptMotionControllers( false )
end

function modifier_mars_spear_of_mars_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mars_spear_of_mars_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end

function modifier_mars_spear_of_mars_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_mars_spear_of_mars_lua:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_mars_spear_of_mars_lua:OnIntervalThink()
end

--------------------------------------------------------------------------------
-- Motion Effects
function modifier_mars_spear_of_mars_lua:UpdateHorizontalMotion( me, dt )
	-- check projectile data
	if not self.ability.projectiles[self.projectile] then
		self:Destroy()
		return
	end

	-- get location
	local data = self.ability.projectiles[self.projectile]

	if not data.active then return end

	-- move parent to projectile location
	self:GetParent():SetOrigin( data.location + data.direction*60 )
end

function modifier_mars_spear_of_mars_lua:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end


modifier_mars_spear_of_mars_lua_checker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mars_spear_of_mars_lua_checker:IsHidden()
	return true
end

function modifier_mars_spear_of_mars_lua_checker:IsDebuff()
	return true
end

function modifier_mars_spear_of_mars_lua_checker:IsPurgable()
	return true
end

function modifier_mars_spear_of_mars_lua_checker:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end
if IsServer() then
function modifier_mars_spear_of_mars_lua_checker:OnTakeDamage(keys)
	local parent = self:GetParent()	
	if keys.inflictor and keys.unit then
		if keys.unit == parent and keys.inflictor:GetAbilityName() == "mars_arena_of_blood" then
			self:Destroy()
		end
	end
end
end

modifier_mars_spear_of_mars_lua_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_mars_spear_of_mars_lua_debuff:IsHidden()
	return false
end

function modifier_mars_spear_of_mars_lua_debuff:IsDebuff()
	return true
end

function modifier_mars_spear_of_mars_lua_debuff:IsStunDebuff()
	return true
end

function modifier_mars_spear_of_mars_lua_debuff:IsPurgable()
	return true
end

function modifier_mars_spear_of_mars_lua_debuff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_mars_spear_of_mars_lua_debuff:OnCreated( kv )
	if not IsServer() then return end
	self.projectile = kv.projectile
end

function modifier_mars_spear_of_mars_lua_debuff:OnRefresh( kv )
end

function modifier_mars_spear_of_mars_lua_debuff:OnRemoved()
	if not IsServer() then return end
	-- destroy tree
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), 120, false )
end

function modifier_mars_spear_of_mars_lua_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_mars_spear_of_mars_lua_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_mars_spear_of_mars_lua_debuff:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_mars_spear_of_mars_lua_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_mars_spear_of_mars_lua_debuff:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf"
end

function modifier_mars_spear_of_mars_lua_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_mars_spear_of_mars_lua_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_mars_spear.vpcf"
end


modifier_mars_spear_of_mars_linger_thinker = class({})

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:GetModifierAura()
	return "modifier_mars_spear_of_mars_debuff"
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:GetAuraRadius()
	return self.radius
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor("shard_radius")
	if IsServer() then
		EmitSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
		self.nFXIndex = ParticleManager:CreateParticle( "particles/custom/mars_linger_fire.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetAbsOrigin() )
	end
end

--------------------------------------------------------------------------------

function modifier_mars_spear_of_mars_linger_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
		ParticleManager:DestroyParticle( self.nFXIndex, false )
	end
end


modifier_mars_spear_of_mars_debuff = class({})


function modifier_mars_spear_of_mars_debuff:IsHidden()
	return true
end


function modifier_mars_spear_of_mars_debuff:OnCreated( kv )
	if IsServer() then
        local interval = self:GetAbility():GetSpecialValueFor("shard_damage_interval")
        self.damage = self:GetAbility():GetSpecialValueFor("shard_dps") * interval
		self:OnIntervalThink()
		self:StartIntervalThink(interval)
		EmitSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

function modifier_mars_spear_of_mars_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_mars_spear_of_mars_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -20
end

function modifier_mars_spear_of_mars_debuff:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

-----------------------------------------------------------------------------

function modifier_mars_spear_of_mars_debuff:OnIntervalThink()
	if IsServer() then
		local damageInfo = 
		{
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		ApplyDamage( damageInfo )

		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_base_attack_impact_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end