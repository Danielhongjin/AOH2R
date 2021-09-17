require("lib/warning")
boss_aghanim_staff_beams = class({})

LinkLuaModifier( "modifier_aghanim_staff_beams_thinker", "abilities/bosses/boss_aghanim_staff_beams", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_staff_beams_linger_thinker", "abilities/bosses/boss_aghanim_staff_beams", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_staff_beams_debuff", "abilities/bosses/boss_aghanim_staff_beams", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_cooldown_lock", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)


----------------------------------------------------------------------------------------

function boss_aghanim_staff_beams:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_burn.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_linger.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/staff_beam_tgt_ring.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_debug_ring.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context )
end

--------------------------------------------------------------------------------

function boss_aghanim_staff_beams:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_aghanim_staff_beams:OnAbilityPhaseStart()
	if IsServer() then
		StartSoundEventFromPositionReliable( "Aghanim.StaffBeams.WindUp", self:GetCaster():GetAbsOrigin() )
		self.nChannelFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_beam_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		self.vecTargets = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
		for k,enemy in pairs ( self.vecTargets ) do
			if enemy ~= nil then
				enemy.nWarningFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_debug_ring.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
				ParticleManager:SetParticleControl( enemy.nWarningFXIndex, 0, enemy:GetAbsOrigin() )
				local fx = aoe_particle(enemy, self:GetCastPoint(), enemy:GetAbsOrigin(), self:GetSpecialValueFor("beam_radius"), 2)	
				enemy.vSourceLoc = enemy:GetAbsOrigin()
			end
		end
	end
	return true
end

--------------------------------------------------------------------------------

function boss_aghanim_staff_beams:OnSpellStart()
	if IsServer() then
		--EmitSoundOn( "Aghanim.ShardAttack.Channel", self:GetCaster() )
		local caster = self:GetCaster()
		EmitSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		self.cooldown_lock = caster:AddNewModifier(caster, self, "modifier_cooldown_locked", {duration = self:GetChannelTime()})
		self.Projectiles = {}
		
		for k,enemy in pairs ( self.vecTargets ) do
			if enemy ~= nil then
				local hBeamThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_aghanim_staff_beams_thinker", { duration = self:GetChannelTime() }, enemy.vSourceLoc, self:GetCaster():GetTeamNumber(), false )
				ParticleManager:DestroyParticle( enemy.nWarningFXIndex, false )
				local projectile =
				{
					Target = enemy,
					Source = hBeamThinker,
					Ability = self,
					EffectName = "",
					iMoveSpeed = self:GetSpecialValueFor( "beam_speed" ),
					vSourceLoc = enemy.vSourceLoc,
					bDodgeable = false,
					bProvidesVision = false,
					flExpireTime = GameRules:GetGameTime() + self:GetChannelTime(),
					bIgnoreObstructions = true,
					bSuppressTargetCheck = true,
				}

				projectile.hThinker = hBeamThinker

				local nProjectileHandle = ProjectileManager:CreateTrackingProjectile( projectile )
				projectile.nProjectileHandle = nProjectileHandle

				local nBeamFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam.vpcf", PATTACH_CUSTOMORIGIN, enemy )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_staff_fx", self:GetCaster():GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 1, projectile.hThinker, PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, projectile.hThinker:GetOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFXIndex, 9, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
				projectile.nFXIndex = nBeamFXIndex

				table.insert( self.Projectiles, projectile )
			end
		end
		--self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_aghanim_staff_beams", kv )
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_staff_beams:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		local Projectile = nil
		for k,v in pairs( self.Projectiles ) do
			if v.nProjectileHandle == nProjectileHandle then
				Projectile = v 
				break
			end
		end

		if Projectile == nil then
			return
		end

		local vLocation = ProjectileManager:GetTrackingProjectileLocation( nProjectileHandle )
		if Projectile.hThinker ~= nil and not Projectile.hThinker:IsNull() then
			vLocation = GetGroundPosition( vLocation, Projectile.hThinker )
			Projectile.hThinker:SetOrigin( vLocation )

			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 1, vLocation )
			ParticleManager:SetParticleControlFallback( Projectile.nFXIndex, 9, self:GetCaster():GetAbsOrigin() )
		end
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_staff_beams:OnChannelThink( flInterval )
	if IsServer() then
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_staff_beams:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
		StopSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		StopSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Stop", self:GetCaster() )

		for _,v in pairs ( self.Projectiles ) do
			ParticleManager:DestroyParticle( v.nFXIndex, false )
			if v.hThinker and v.hThinker:IsNull() == false then
				UTIL_Remove( v.hThinker )
			end
		end
		if self.cooldown_lock then
			self.cooldown_lock:Destroy()
		end
		--self:GetCaster():RemoveModifierByName( "modifier_aghanim_staff_beams" )
	end
end


modifier_aghanim_staff_beams_debuff = class({})

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_debuff:IsHidden()
	return true
end


-----------------------------------------------------------------------------

function modifier_aghanim_staff_beams_debuff:OnCreated( kv )
	if IsServer() then
		self.beam_dps = self:GetAbility():GetSpecialValueFor( "beam_dps" )
		self.beam_dps_pct = self:GetAbility():GetSpecialValueFor( "beam_dps_pct" )
		self.damage_interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
		self:OnIntervalThink()
		self:StartIntervalThink( self.damage_interval )

		EmitSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_staff_beams_debuff:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Huskar.Burning_Spear", self:GetParent() )
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_staff_beams_debuff:OnIntervalThink()
	if IsServer() then
		local flHealthPctDamage = self.beam_dps_pct * self:GetParent():GetMaxHealth() / 100
		local flDamage = self.beam_dps + flHealthPctDamage
		local damageInfo = 
		{
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage * self.damage_interval,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		ApplyDamage( damageInfo )

		local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_beam_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

-----------------------------------------------------------------------------


modifier_aghanim_staff_beams_linger_thinker = class({})

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:GetModifierAura()
	return "modifier_aghanim_staff_beams_debuff"
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:GetAuraRadius()
	return self.beam_radius
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:OnCreated( kv )
	self.beam_radius = self:GetAbility():GetSpecialValueFor( "beam_radius" )
    
	if IsServer() then
		EmitSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
		self.nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/staff_beam_linger.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetParent():GetAbsOrigin() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self.beam_radius, 1, 1 ) )
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn( "n_black_dragon.Fireball.Target", self:GetParent() )
		ParticleManager:DestroyParticle( self.nFXIndex, false )
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_staff_beams_linger_thinker:OnRefresh( kv )
	self.beam_radius = self:GetAbility():GetSpecialValueFor( "beam_radius" )
end

--------------------------------------------------------------------------------


modifier_aghanim_staff_beams_thinker = class({})

-----------------------------------------------------------------------------

function modifier_aghanim_staff_beams_thinker:OnCreated( kv )
	if IsServer() then
		self.linger_time = self:GetAbility():GetSpecialValueFor( "linger_time" )
		self.linger_create_interval = self:GetAbility():GetSpecialValueFor( "linger_create_interval" )
		self:StartIntervalThink( self.linger_create_interval )
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_staff_beams_thinker:OnIntervalThink()
	if IsServer() then
		CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_aghanim_staff_beams_linger_thinker", { duration = self.linger_time }, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false )
	end
end

-----------------------------------------------------------------------------