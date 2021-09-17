boss_aghanim_summon_portals = class( {} )

LinkLuaModifier( "modifier_aghanim_portal_spawn_effect", "abilities/bosses/boss_aghanim_summon_portals", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_summon_portals_thinker", "abilities/bosses/boss_aghanim_summon_portals", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_cooldown_lock", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
----------------------------------------------------------------------------------------

function boss_aghanim_summon_portals:Precache( context )
	PrecacheResource( "particle", "particles/econ/events/ti10/portal/portal_open_bad.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/portal_summon.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_portal_summon.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_portal_emit.vpcf", context )
	PrecacheResource( "particle", "particles/econ/events/ti10/portal/portal_emit_large.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_ghost.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_stomp_magical.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_impact_magical.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context )

	PrecacheUnitByNameSync( "npc_dota_creature_aghanim_minion", context, -1 )
	PrecacheUnitByNameSync( "npc_dota_boss_aghanim_spear", context, -1 )

	self.PORTAL_MODE_ALL_SPEARS = 0
	self.PORTAL_MODE_ALL_ENEMIES = 1
	self.PORTAL_MODE_BOTH = 2

	self.nLastPortalMode = self.PORTAL_MODE_ALL_ENEMIES
	self.nMode = 0
	self.nDepthRemaining = 20
	self.nPortals = 0
	self.nNumPortalsThisCast = 0
	self.flPortalSummmonTime = self:GetSpecialValueFor( "portal_time" )
	self.flStartGestureTime = 999999999999
	
	self.bSynchedPortalRelease = false
end

--------------------------------------------------------------------------------

function boss_aghanim_summon_portals:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_aghanim_summon_portals:OnAbilityPhaseStart()
	if IsServer() then
		self.nPortals = self:GetPortalCount()
		self.flPortalSummmonTime = self:GetSpecialValueFor( "portal_time" )
		
		self.nChannelFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_portal_summon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		EmitSoundOn( "Hero_ElderTitan.EchoStomp.Channel", self:GetCaster() )

		self.staff_crush_radius = self:GetSpecialValueFor( "staff_crush_radius" )
		self.staff_crush_damage = self:GetSpecialValueFor( "staff_crush_damage" )
		self.staff_crush_stun_duration = self:GetSpecialValueFor( "staff_crush_stun_duration" )
		self.staff_crush_delay = self:GetSpecialValueFor( "staff_crush_delay" )


		local vToTarget = self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()
		vToTarget.z = 0
		vToTarget = vToTarget:Normalized()

		self.vStaffEndPos = self:GetCaster():GetAbsOrigin() + ( vToTarget * 200.0 )--+ ( self:GetCaster():GetRightVector() * -30 )
		self.vStaffEndPos = GetGroundPosition( self.vStaffEndPos, self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_attack_telegraph.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self.vStaffEndPos )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.staff_crush_radius, 1.6, 1.6 ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 255, 0, 0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
	return true
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:OnChannelThink( flInterval )
	if IsServer() then
		if self.nPortals > 0 and GameRules:GetGameTime() > self.flNextPortalTime then
			self.flNextPortalTime = GameRules:GetGameTime() + self.flPortalInterval
			if self.nNumPortalsInLine > 0 then
				self:CreateNextPortalAlongLine()
				self.nNumPortalsInLine = self.nNumPortalsInLine - 1
				self.nNumPortalsThisCast = self.nNumPortalsThisCast + 1
			end

			if self.nNumPortalsNearHeroes > 0 then
				self:CreateNearHeroPortal()
				self.nNumPortalsNearHeroes = self.nNumPortalsNearHeroes - 1
				self.nNumPortalsThisCast = self.nNumPortalsThisCast + 1
			end
		end

		if self.bHasStaffCrushed == false then
			self.staff_crush_delay = self.staff_crush_delay - flInterval
			if self.staff_crush_delay < 0 then
				self.bHasStaffCrushed = true
				self:StaffCrush()
			end
		end

		if GameRules:GetGameTime() > self.flStartGestureTime then
			self:GetCaster():StartGesture( ACT_DOTA_IDLE )
			self.flStartGestureTime = 9999999999999
		end
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
		self:GetCaster():RemoveGesture( ACT_DOTA_IDLE )
		if self.cooldown_lock then
			self.cooldown_lock:Destroy()
		end
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		self.cooldown_lock = caster:AddNewModifier(caster, self, "modifier_cooldown_locked", {duration = self:GetChannelTime()})
		self.flStartGestureTime = GameRules:GetGameTime() + 2.5
		self.bHasStaffCrushed = false

		self.flPortalInterval = self:GetChannelTime() / self.nPortals 
		self.flNextPortalTime = -1
		self.nDepthRemaining = self:GetSpecialValueFor( "total_portal_depth" )
		self.nLastPortalMode = self.nMode
		self.nMode = self:GetPortalMode()

		self.nNumPortalsThisCast = 0

		self.nNumPortalsInLine = self:GetSpecialValueFor( "base_portals" ) 
		self.nNumPortalsNearHeroes = self.nPortals - self.nNumPortalsInLine

		if self.nMode == self.PORTAL_MODE_ALL_SPEARS then
			local vMidPoint = nil
			
			local vLineDir = nil
			self.Heroes = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )

			vMidPoint = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 500
			vLineDir = self:GetCaster():GetRightVector()

			vLineDir.z = 0.0
			vLineDir = vLineDir:Normalized()

			local nPortalsRemaining = self.nNumPortalsInLine - 1 
			local flLineStep = 450
			local flTotalLineDist = flLineStep * self.nNumPortalsInLine
			local vFirstPortalPos = vMidPoint - ( vLineDir * ( flLineStep * nPortalsRemaining  / 2 )  )

			self.SpearLinePositions = {}
			table.insert( self.SpearLinePositions, vFirstPortalPos )
			
			for i=1,nPortalsRemaining do
				local vNewPortalPos = vFirstPortalPos + ( vLineDir * i * flLineStep )
				table.insert( self.SpearLinePositions, vNewPortalPos )
			end
		end
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:StaffCrush()
	if IsServer() then
		
		local nFXCastIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_stomp_magical.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( nFXCastIndex, 0, self.vStaffEndPos )
		ParticleManager:SetParticleControl( nFXCastIndex, 1, Vector( self.radius, self.radius, self.radius ) )
		ParticleManager:ReleaseParticleIndex( nFXCastIndex )

		EmitSoundOn( "Hero_ElderTitan.EchoStomp", self:GetCaster() )

		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self.vStaffEndPos, self:GetCaster(), self.staff_crush_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false then
				local damageInfo = 
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = self.staff_crush_damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = self,
				}

				ApplyDamage( damageInfo )
				
				enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self.staff_crush_stun_duration } )

				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_impact_magical.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy )
				local vDirection = enemy:GetOrigin() - self.vStaffEndPos
				vDirection.z = 0.0
				vDirection = vDirection:Normalized()

				ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
				ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:GetPortalCount()
	if IsServer() then
		local nBasePortals = self:GetSpecialValueFor( "base_portals" )
		local nHealthPctPerPortal = self:GetSpecialValueFor( "portal_health_pct" )
		local nAdditionalPortals = math.floor( ( 100 - self:GetCaster():GetHealthPercent() )  / nHealthPctPerPortal )

		return nBasePortals + nAdditionalPortals
	end

	return 0
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:GetPortalMode()
	if IsServer() then	
		return self.PORTAL_MODE_ALL_SPEARS		
	end
	return 0
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:CreateNearHeroPortal()
	if IsServer() then
		local nCountLeft = self.nNumPortalsNearHeroes 
		if nCountLeft <= 0 then
			return
		end

		local Heroes = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
		if #Heroes == 0 then
			return
		end

		local hTarget = Heroes[ RandomInt( 1, #Heroes ) ]
		if hTarget == nil then
			return
		end

		local vToAghanim = self:GetCaster():GetAbsOrigin() - hTarget:GetAbsOrigin() 
		vToAghanim.z = 0.0
		vToAghanim = vToAghanim:Normalized()

		local vPos = hTarget:GetAbsOrigin() - vToAghanim * RandomFloat( self:GetSpecialValueFor( "min_portal_offset" ), self:GetSpecialValueFor( "max_portal_offset" ) )
		if GridNav:CanFindPath( hTarget:GetAbsOrigin(), vPos ) == false then
			return
		end

		local flDuration = 0.5 + ( self:GetChannelStartTime() + self:GetChannelTime() ) - GameRules:GetGameTime() - ( nCountLeft * 0.3 )

		local kv =
		{
			duration = flDuration,
			mode = self.PORTAL_MODE_ALL_SPEARS,
			depth = 0,
			target_entindex = hTarget:entindex(),
		}

		CreateModifierThinker( self:GetCaster(), self, "modifier_aghanim_summon_portals_thinker", kv, vPos, self:GetCaster():GetTeamNumber(), false )
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_summon_portals:CreateNextPortalAlongLine()
	if IsServer() then
		local nCountLeft = #self.SpearLinePositions 
		if nCountLeft == 0 then
			return
		end

		local vPos = self.SpearLinePositions[ 1 ]
		
		local hTarget = nil
		if #self.Heroes == 0 then
			local Heroes = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
			if #Heroes == 0 then
				return
			end
			hTarget = Heroes[ RandomInt( 1, #Heroes ) ]
		else
			local nIndex = RandomInt( 1, #self.Heroes )
			hTarget = self.Heroes[ nIndex ]
			table.remove( self.Heroes, nIndex )
		end
		 
		if hTarget == nil then
			return
		end

		local flDuration = 0.5 + ( self:GetChannelStartTime() + self:GetChannelTime() ) - GameRules:GetGameTime() - ( nCountLeft * 0.3 )
		table.remove( self.SpearLinePositions, 1 )

		local kv =
		{
			duration = flDuration,
			mode = self.PORTAL_MODE_ALL_SPEARS,
			depth = 0,
			target_entindex = hTarget:entindex(),
		}

		CreateModifierThinker( self:GetCaster(), self, "modifier_aghanim_summon_portals_thinker", kv, vPos, self:GetCaster():GetTeamNumber(), false )
	end
end

-------------------------------------------------------------------------------

modifier_aghanim_portal_spawn_effect = class({})

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:IsHidden()
	return true
end

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:OnCreated( kv )
	if IsServer() then
		self:StartIntervalThink( 1.0 )
	end
end


--------------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:OnIntervalThink()
	if IsServer() then
		self:GetParent():RemoveEffects( EF_NODRAW )
		self:StartIntervalThink( -1 )
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:GetPriority()
	return MODIFIER_PRIORITY_ULTRA + 20000
end

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:GetEffectName()
	return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

--------------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:GetModifierModelScale( params )
	return ( self:GetElapsedTime() / self:GetDuration() - 1.0 ) * 100
end

---------------------------------------------------------------------------

function modifier_aghanim_portal_spawn_effect:CheckState()
	local state =
	{
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end


modifier_aghanim_summon_portals_thinker = class({})

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:OnCreated( kv )
	if IsServer() then
		self.nMode = kv.mode 
		self.hTarget = EntIndexToHScript( kv.target_entindex )
		self.nDepth = kv.depth

		local vFwd = nil
		if self.hTarget == nil then
			vFwd = self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()
			vFwd = vFwd:Normalized()
		else
			vFwd = self.hTarget:GetAbsOrigin() - self:GetParent():GetAbsOrigin()
			vFwd = vFwd:Normalized()
		end

		local szEffect = nil
		if self.nMode == self:GetAbility().PORTAL_MODE_ALL_SPEARS and self.hTarget then
			self:CreateSpear()
			szEffect = "particles/creatures/aghanim/portal_summon.vpcf"
			self:StartIntervalThink( 0.1 )
		else
			self:CreateEnemies()
			szEffect = "particles/creatures/aghanim/portal_summon.vpcf"
		end

		EmitSoundOn( "SeasonalConsumable.TI10.Portal.Open", self:GetParent() )
		EmitSoundOn( "SeasonalConsumable.TI10.Portal.Loop", self:GetParent() )

		self.nPortalFX = ParticleManager:CreateParticle( szEffect, PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( self.nPortalFX, 0, self:GetParent():GetAbsOrigin() )
		ParticleManager:SetParticleControlForward( self.nPortalFX, 0, vFwd )

		AddFOWViewer( DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), 300.0, self:GetDuration(), false )
		GridNav:DestroyTreesAroundPoint( self:GetParent():GetAbsOrigin(), 300, false )
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:CreateSpear()
	if IsServer() then
		self.hSpear = CreateUnitByName( "npc_dota_boss_aghanim_spear", self:GetParent():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
		if self.hSpear then
			self.hSpear:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), false )
			self.hSpear:SetOwner( self:GetCaster() )
			self.hSpear:AddEffects( EF_NODRAW )
			self.hSpear:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_rooted", {} )
			self.hSpear:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_hero_statue_pedestal", {} )
			
			--self.hSpear:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_portal_spawn_effect", {} )
			self.hSpear:FaceTowards( self.hTarget:GetAbsOrigin() )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
	}
	return funcs
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:GetModifierIgnoreCastAngle( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:OnIntervalThink()
	if IsServer() then
		if self.hSpear then
			self.hSpear:RemoveEffects( EF_NODRAW )
			self.hSpear:FaceTowards( self.hTarget:GetAbsOrigin() )
		end
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:CreateEnemies()
	if IsServer() then
		self.Summons = {}
		if 1 then
			nCount = 2
			for n=1,nCount do 
				local vSpawnPos = self:GetParent():GetAbsOrigin() + RandomVector( 25 * nCount )
				local hSummon = CreateUnitByName( "npc_dota_creature_aghanim_minion", vSpawnPos, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
				if hSummon ~= nil then
					table.insert( self.Summons, hSummon )
					hSummon.nDisableResistance = hSummon:GetDisableResistance( )
					hSummon.nUltimateDisableResistance = hSummon:GetUltimateDisableResistance( )
					hSummon:SetDisableResistance( 0 )
					hSummon:SetUltimateDisableResistance( 0 )
					hSummon:SetOwner( self:GetCaster() )
					hSummon:SetDeathXP( 0 )
					hSummon:SetMinimumGoldBounty( 0 )
					hSummon:SetMaximumGoldBounty( 0 )
					hSummon:AddEffects( EF_NODRAW )
					hSummon:SetAbsAngles( 0, RandomFloat( 0, 360 ), 0 )
					hSummon:SetMaterialGroup( "1" )
					hSummon:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_portal_spawn_effect", { duration = self:GetRemainingTime() } )
	
				end
			end
		else
			local PossibleSummons = GameRules.Aghanim:GetSummonsForAghanim()
			local Summon = nil

			while Summon == nil and self.nDepth > 1 do
				for _,CurSummon in pairs( PossibleSummons ) do
					if CurSummon[ "depth" ] == self.nDepth then
						Summon = CurSummon
						break
					end
				end

				if Summon == nil then
					self.nDepth = self.nDepth - 1
				end
			end

			if Summon then
				local nCount = math.max( 1, 5 - math.floor( self.nDepth / 2 ) )
				for n=1,nCount do 
					local vSpawnPos = self:GetParent():GetAbsOrigin() + RandomVector( 25 * nCount )
					local hSummon = CreateUnitByName( Summon[ "unit_name" ], vSpawnPos, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
					if hSummon ~= nil then
						table.insert( self.Summons, hSummon )
						hSummon.nDisableResistance = hSummon:GetDisableResistance( )
						hSummon.nUltimateDisableResistance = hSummon:GetUltimateDisableResistance( )
						hSummon:SetDisableResistance( 0 )
						hSummon:SetUltimateDisableResistance( 0 )
						hSummon:SetOwner( self:GetCaster() )
						hSummon:SetDeathXP( 0 )
						hSummon:SetMinimumGoldBounty( 0 )
						hSummon:SetMaximumGoldBounty( 0 )
						hSummon:AddEffects( EF_NODRAW )
						hSummon:SetAbsAngles( 0, RandomFloat( 0, 360 ), 0 )
						hSummon:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_portal_spawn_effect", { duration = self:GetRemainingTime() } )
		
					end
				end
			end
		end		
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:OnDestroy()
	if IsServer() then
		if self.nMode == self:GetAbility().PORTAL_MODE_ALL_SPEARS then
			self:LaunchSpear()
		else
			self:ReleaseEnemies()
		end
		StopSoundOn( "SeasonalConsumable.TI10.Portal.Open", self:GetParent() )
		StopSoundOn( "SeasonalConsumable.TI10.Portal.Loop", self:GetParent() )

		ParticleManager:DestroyParticle( self.nPortalFX, false )
		UTIL_Remove( self:GetParent() )
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:LaunchSpear()
	if IsServer() then
		if self.hSpear ~= nil then
			self.hSpear:AddEffects( EF_NODRAW )
			self.hSpear:ForceKill( false )
		end

		local hSpear = self:GetCaster():FindAbilityByName( "boss_aghanim_spear" )
		if hSpear and self.hTarget and self.hTarget:IsNull() == false then
			hSpear:EndCooldown()

			EmitSoundOn(  "SeasonalConsumable.TI10.Portal.Emit", self:GetParent() )
			local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_portal_emit.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			hSpear:LaunchSpear( self.hTarget:GetAbsOrigin(), self:GetParent():GetAbsOrigin() )
		else
			print( "No spear, or no target?" )
		end
	end
end

-----------------------------------------------------------------------------

function modifier_aghanim_summon_portals_thinker:ReleaseEnemies()
	if IsServer() then
		for _, Summon in pairs ( self.Summons ) do
			EmitSoundOn(  "SeasonalConsumable.TI10.Portal.Emit", Summon )
			local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_portal_emit.vpcf", PATTACH_CUSTOMORIGIN, nil )
			ParticleManager:SetParticleControl( nFXIndex, 0, Summon:GetAbsOrigin() )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			Summon:RemoveModifierByName( "modifier_aghanim_portal_spawn_effect" )
			Summon:SetAcquisitionRange( 5000 )
			Summon:SetDayTimeVisionRange( 5000 )
			Summon:SetNightTimeVisionRange( 5000 )
			Summon:SetDisableResistance( Summon.nDisableResistance )
			Summon:SetUltimateDisableResistance( Summon.nUltimateDisableResistance )
			Summon.bBossMinion = true
			FindClearSpaceForUnit( Summon, Summon:GetAbsOrigin(), false )
		end
	end
end