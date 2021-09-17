
boss_aghanim_spell_swap = class({})

LinkLuaModifier( "modifier_aghanim_spell_swap", "abilities/bosses/boss_aghanim_spell_swap", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghanim_spell_swap_crystal", "abilities/bosses/boss_aghanim_spell_swap", LUA_MODIFIER_MOTION_BOTH )

----------------------------------------------------------------------------------------

function boss_aghanim_spell_swap:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_beam_channel.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_spell_swap_beam.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_wisp/wisp_tether_hit.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_spellswap_replenish.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_spellswap_ambient.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_destroy.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_crystal_impact.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts", context )

	PrecacheResource( "model", "models/gameplay/aghanim_crystal.vmdl", context )
end

--------------------------------------------------------------------------------

function boss_aghanim_spell_swap:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_aghanim_spell_swap:OnAbilityPhaseStart()
	if IsServer() then
		self.nChannelFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_beam_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end


-------------------------------------------------------------------------------

function boss_aghanim_spell_swap:GetChannelTime()
	if IsServer() then
		local flChannelTime = self.BaseClass.GetChannelTime( self )
		local nHealthPct = self:GetCaster():GetHealthPercent()
		if nHealthPct < 50 then
			flChannelTime = flChannelTime - 1.0
		end
		if nHealthPct < 25 then
			flChannelTime = flChannelTime - 1.0
		end
		return flChannelTime
	end
	return self.BaseClass.GetChannelTime( self )
end

-------------------------------------------------------------------------------

function boss_aghanim_spell_swap:OnChannelThink( flInterval )
	if IsServer() then
	end
end

-------------------------------------------------------------------------------

function boss_aghanim_spell_swap:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )

		for _,nFXIndex in pairs ( self.nBeamFXIndices ) do
			ParticleManager:DestroyParticle( nFXIndex, true )
		end

		StopSoundOn( "Hero_Pugna.LifeDrain.Loop", self:GetCaster() )

		for k,hHero in pairs ( self.Heroes ) do
			if hHero ~= nil and hHero:IsRealHero() then
				hHero:RemoveModifierByName( "modifier_arc_warden_spark_wraith_purge" )
				hHero:AddNewModifier( self:GetCaster(), self, "modifier_aghanim_spell_swap", {} )	
			end
		end
	end
end

--------------------------------------------------------------------------------

function boss_aghanim_spell_swap:OnSpellStart()
	if IsServer() then
		self.nBeamFXIndices = {} 

		local hSummonPortals = self:GetCaster():FindAbilityByName( "aghanim_summon_portals" )
		if hSummonPortals then
			local kv =
			{
				duration = self:GetChannelTime(),
				mode = hSummonPortals.PORTAL_MODE_ALL_ENEMIES,
				depth = 0,
				target_entindex = -1,
			}

			local vRightPos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetRightVector() * 300
			local vLeftPos = self:GetCaster():GetAbsOrigin() - self:GetCaster():GetRightVector() * 300
			CreateModifierThinker( self:GetCaster(), self, "modifier_aghanim_summon_portals_thinker", kv, vRightPos, self:GetCaster():GetTeamNumber(), false )
			CreateModifierThinker( self:GetCaster(), self, "modifier_aghanim_summon_portals_thinker", kv, vLeftPos, self:GetCaster():GetTeamNumber(), false )
		end

		EmitSoundOn( "Hero_Pugna.LifeDrain.Cast", self:GetCaster() )
		EmitSoundOn( "Hero_Pugna.LifeDrain.Loop", self:GetCaster() )

		self.Heroes = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false )
		for k,hHero in pairs ( self.Heroes ) do
			if hHero ~= nil and hHero:IsRealHero() then

				local nNumAghDummies = 0
				for j=1,4 do		
					local szName = tostring( "aghanim_empty_spell" .. j )
					local hDummyAbility = hHero:FindAbilityByName( szName )
					if hDummyAbility then
						nNumAghDummies = nNumAghDummies + 1
					end
				end	

				if nNumAghDummies == 4 then
					print( "I have 4 agh dummies!  Getting slowed." )
					hHero:AddNewModifier( self:GetCaster(), self, "modifier_arc_warden_spark_wraith_purge", { duration = self:GetChannelTime() } )
				end
				
				local nBeamFX = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_spell_swap_beam.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )

				local szAttachment = "attach_hand_R"
				if RandomInt( 0, 1 ) == 1 then
					szAttachment = "attach_lower_hand_R"
				end
				ParticleManager:SetParticleControlEnt( nBeamFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, szAttachment, self:GetCaster():GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nBeamFX, 1, hHero, PATTACH_POINT_FOLLOW, "attach_hitloc", hHero:GetAbsOrigin(), true )
				ParticleManager:SetParticleControl( nBeamFX, 11, Vector( 1, 0, 0 ) )

				table.insert( self.nBeamFXIndices, nBeamFX )	
			end
		end
	end
end

--------------------------------------------------------------------------------

modifier_aghanim_spell_swap = class({})

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap:IsHidden()
	return false
end

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap:IsPurgable()
	return false
end

-----------------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:OnCreated( kv )
	if IsServer() then
		self:DisableSpell()
	end
end

----------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

--------------------------------------------------------------------------------


function modifier_aghanim_spell_swap:OnDeath( params )
	if IsServer() then
		if params.unit == self.hCrystal then
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:DisableSpell()
	if IsServer() then
		local NormalAbilities = {}
		for i=0,DOTA_MAX_ABILITIES-1 do
			local hAbility = self:GetParent():GetAbilityByIndex( i )
			if hAbility and not hAbility:IsCosmetic( nil ) and not hAbility:IsAttributeBonus() and hAbility:GetAssociatedPrimaryAbilities() == nil and not hAbility:IsHidden() and not hAbility.bAghDisabled == true and not hAbility.bAghDummy == true and hAbility:IsActivated() then
				print( "considering ability for disable: " .. hAbility:GetAbilityName() )
				table.insert( NormalAbilities, hAbility )
			end
		end

		local nNextAghDummy = nil
		for j=1,4 do		
			local szName = tostring( "aghanim_empty_spell" .. j )
			local hDummyAbility = self:GetParent():FindAbilityByName( szName )
			nNextAghDummy = j
			if not hDummyAbility then
				break
			end
		end	

	
		local nIndexToDisable = math.random( 1, #NormalAbilities )
		local hAbilityToDisable = NormalAbilities[ nIndexToDisable ]

		if nNextAghDummy == nil or hAbilityToDisable == nil then
			self:Destroy()
			print( "Cannot disable spell:" )
			print( "Next agh dummy: " .. nNextAghDummy )
			if hAbilityToDisable ~= nil then
				print( "hAbilityToDisable " .. hAbilityToDisable:GetAbilityName() )
			end
			return
		end

		local hNewDummyAbility = self:GetParent():AddAbility( tostring( "aghanim_empty_spell" .. nNextAghDummy ) )
		if hNewDummyAbility then
			print( "adding dummy ability for disable: " .. hNewDummyAbility:GetAbilityName() )
			hNewDummyAbility:UpgradeAbility( true )
			hNewDummyAbility:SetActivated( true )
			hNewDummyAbility.bAghDummy = true
			hNewDummyAbility.nOriginalIndex = hNewDummyAbility:GetAbilityIndex()
		end
		

		hAbilityToDisable.bAghDisabled = true
		print( "disabling " .. hAbilityToDisable:GetAbilityName() )
		if hAbilityToDisable:GetToggleState() then
			--print( "toggling ability off" )
			hAbilityToDisable:OnToggle()
		end

		hAbilityToDisable:SetActivated( false )
		hAbilityToDisable.nOriginalIndex = hAbilityToDisable:GetAbilityIndex()

		self.hDisabledAbility = hAbilityToDisable
		self.hDummyAbility = hNewDummyAbility

		self:GetParent():SwapAbilities( self.hDisabledAbility:GetAbilityName(), self.hDummyAbility:GetAbilityName(), false, true )
		self.hDummyAbility:SetActivated( false )

		--self.hDisabledAbility:SetAbilityIndex( self.hDummyAbility.nOriginalIndex )
		--self.hDisabledAbility:SetHidden( true )
		--self.hDummyAbility:SetAbilityIndex( self.hDisabledAbility.nOriginalIndex )
		--self.hDummyAbility:SetHidden( false )

		self.hCrystal = CreateUnitByName( "npc_dota_boss_aghanim_crystal", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster():GetOwner(), self:GetCaster():GetTeamNumber() )
		if self.hCrystal then
			self.hCrystal:SetControllableByPlayer( self:GetCaster():GetPlayerOwnerID(), false )
			self.hCrystal:SetOwner( self:GetCaster() )
			self.hCrystal:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_aghanim_spell_swap_crystal", {} )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:RestoreSpell()
	if IsServer() then
		if self.hDisabledAbility and self.hDummyAbility then
			self.hDisabledAbility:SetActivated( true )
			self.hDisabledAbility.bAghDisabled = false
			self.hDisabledAbility:SetHidden( false )
			self:GetParent():RemoveAbilityFromIndexByName( self.hDisabledAbility:GetAbilityName() )
			self:GetParent():SetAbilityByIndex( self.hDisabledAbility, self.hDisabledAbility.nOriginalIndex ) -- this destroys the dummy spell
			
			if self.hCrystal then
				self.hCrystal:AddEffects( EF_NODRAW )
				if self.hCrystal:IsAlive() then
					self.hCrystal:ForceKill( false )
				end

				local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_destroy.vpcf", PATTACH_CUSTOMORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, self.hCrystal:GetAbsOrigin() )
				ParticleManager:ReleaseParticleIndex( nFXIndex )

				EmitSoundOn( "Hero_Wisp.Spirits.Destroy", self.hCrystal )

				local nFXIndex2 = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_spellswap_replenish.vpcf", PATTACH_CUSTOMORIGIN, nil )	
				ParticleManager:SetParticleControlEnt( nFXIndex2, 0, self.hCrystal, PATTACH_POINT_FOLLOW, "attach_attack1", self.hCrystal:GetAbsOrigin(), true )
				ParticleManager:SetParticleControlEnt( nFXIndex2, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex2 )
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap:OnDestroy()
	if IsServer() then
		self:RestoreSpell()
	end
end


modifier_aghanim_spell_swap_crystal = class({})

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:IsHidden()
	return true
end

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:IsPurgable()
	return false
end

---------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:GetEffectName()
	return "particles/creatures/aghanim/aghanim_crystal_spellswap_ambient.vpcf"
end

----------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

----------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:CheckState()
	local state =
	{
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
	return state
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnCreated( kv )
	if IsServer() then
		self.num_crystal_hits = self:GetAbility():GetSpecialValueFor( "num_crystal_hits" )

		self:GetParent():SetBaseMaxHealth( self.num_crystal_hits * 2 )
		self:GetParent():SetMaxHealth( self.num_crystal_hits * 2 )
		self:GetParent():SetHealth( self.num_crystal_hits * 2 )

		self.flRotationTime = 12.0
		self.flRotationDist = 300.0
		self.flHeight = RandomFloat( 120.0, 180.0 )
		self.flRotation = RandomFloat( 0, 360 )
		self.flRecoverTime = -1

		self:StartIntervalThink( 0.25 )
		
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnIntervalThink()
	if IsServer() then
		if GameRules:GetGameTime() > self.flRecoverTime then
			self.flRotationTime = 12.0
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		self.flRotation = self.flRotation + ( 2.0 * dt * math.pi / self.flRotationTime )
		local flX = self.flRotationDist * math.sin( self.flRotation )
		local flY = self.flRotationDist * math.cos( self.flRotation )
		if self:GetCaster() and self:GetParent() then
			local vNewLocation = self:GetCaster():GetAbsOrigin() + Vector( flX, flY, self:GetParent():GetAbsOrigin().z )
			me:SetOrigin( vNewLocation )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:UpdateVerticalMotion( me, dt )
	if IsServer() then
		local flHeight = GetGroundHeight( self:GetParent():GetAbsOrigin(), self:GetParent() ) + self.flHeight
		local vNewLocation = self:GetParent():GetAbsOrigin()
		vNewLocation.z = flHeight
		me:SetOrigin( vNewLocation )
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnVerticalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:GetAbsoluteNoDamagePhysical( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:GetAbsoluteNoDamageMagical( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:GetAbsoluteNoDamagePure( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_aghanim_spell_swap_crystal:OnAttacked( params )
	if IsServer() then
		if self:GetParent() == params.target then
			local nDamage = 0
			if params.attacker then
				local bDeathWard = params.attacker:FindModifierByName( "modifier_aghsfort_witch_doctor_death_ward" ) ~= nil
				local bValidAttacker = params.attacker:IsRealHero() or bDeathWard
				if not bValidAttacker then
					return 0
				end
			
				nDamage = 2
				if params.attacker:FindModifierByName( "modifier_aghsfort_snapfire_lil_shredder_buff" ) or bDeathWard then
					nDamage = 1
				end

				self.flRotationTime = 36.0
				self.flRecoverTime = GameRules:GetGameTime() + 1.0
				self:GetParent():ModifyHealth( self:GetParent():GetHealth() - nDamage, nil, true, 0 )

				EmitSoundOn( "Hero_Wisp.Spirits.Target", self:GetParent() )

				local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_crystal_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end
		end
	end

	return 0
end