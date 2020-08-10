enchantress_custom_enchant = class({})
LinkLuaModifier( "modifier_enchantress_enchant_lua", "abilities/heroes/enchantress_custom_enchant.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_enchantress_enchant_lua_slow", "abilities/heroes/enchantress_custom_enchant.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_summonbuff", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)

function enchantress_custom_enchant:OnUpgrade()
	if not self.dominate_table then
		self.dominate_table = {}
	end
end

function enchantress_custom_enchant:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local bonus_health = self:GetSpecialValueFor("enchant_health")
	local bonus_damage = self:GetSpecialValueFor("enchant_damage")
	local talent = caster:FindAbilityByName("special_bonus_unique_enchantress_1")
	if talent and talent:GetLevel() > 0 then
		has_talent = true	
	end
	-- add modifier based on target
	if target:IsConsideredHero() then
		local duration = self:GetDuration()
		target:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_enchantress_enchant_lua_slow", -- modifier name
			{ duration = duration } -- kv
		)

		-- dispel target
		target:Purge( true, false, false, false, false )

		-- play effects
		local sound_cast = "Hero_Enchantress.EnchantHero"
		EmitSoundOn( sound_cast, target )
	elseif not target:IsAncient() or has_talent then
		table.insert(self.dominate_table, target)
		if #self.dominate_table > 1 then
			self.dominate_table[1]:ForceKill(true) 
		end
		target:SetBaseMaxHealth(target:GetMaxHealth() + bonus_health)
		target:SetBaseDamageMax(target:GetBaseDamageMax() + bonus_damage)
		target:SetBaseDamageMin(target:GetBaseDamageMin() + bonus_damage)
		target:AddNewModifier(target, nil, "modifier_summonbuff", {id = caster:GetPlayerID()})
		target:AddNewModifier(
			caster, -- player source
			self, -- ability source
			"modifier_enchantress_enchant_lua", -- modifier name
			{ duration = -1 } -- kv
		)
		
		-- dispel target
		target:Purge( false, true, false, false, false )

		-- play effects
		local sound_cast = "Hero_Enchantress.EnchantCreep"
		EmitSoundOn( sound_cast, target )
	end

	-- play effects
	local sound_cast = "Hero_Enchantress.EnchantCast"
	EmitSoundOn( sound_cast, caster )
end

modifier_enchantress_enchant_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_enchantress_enchant_lua:IsHidden()
	return false
end

function modifier_enchantress_enchant_lua:IsDebuff()
	return false
end

function modifier_enchantress_enchant_lua:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_enchantress_enchant_lua:OnCreated( kv )
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()

		-- set controllable
		parent:SetTeam( caster:GetTeamNumber() )
		parent:SetOwner( caster )
		parent:SetControllableByPlayer( caster:GetPlayerOwnerID(), true )
	end
end

function modifier_enchantress_enchant_lua:OnRefresh( kv )
	
end

function modifier_enchantress_enchant_lua:OnDestroy( kv )
	local ability = self:GetAbility()
	table.remove(ability.dominate_table, 1)
end

--------------------------------------------------------------------------------
-- Modifier Effects
-- function modifier_enchantress_enchant_lua:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_XX,
-- 		MODIFIER_EVENT_YY,
-- 	}

-- 	return funcs
-- end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_enchantress_enchant_lua:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Interval Effects
-- function modifier_enchantress_enchant_lua:OnIntervalThink()
-- end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_enchantress_enchant_lua:GetEffectName()
-- 	return "particles/string/here.vpcf"
-- end

-- function modifier_enchantress_enchant_lua:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

-- function modifier_enchantress_enchant_lua:PlayEffects()
-- 	-- Get Resources
-- 	local particle_cast = "string"
-- 	local sound_cast = "string"

-- 	-- Get Data

-- 	-- Create Particle
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_NAME, hOwner )
-- 	ParticleManager:SetParticleControl( effect_cast, iControlPoint, vControlVector )
-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		iControlPoint,
-- 		hTarget,
-- 		PATTACH_NAME,
-- 		"attach_name",
-- 		vOrigin, -- unknown
-- 		bool -- unknown, true
-- 	)
-- 	ParticleManager:SetParticleControlForward( effect_cast, iControlPoint, vForward )
-- 	SetParticleControlOrientation( effect_cast, iControlPoint, vForward, vRight, vUp )
-- 	ParticleManager:ReleaseParticleIndex( effect_cast )

-- 	-- buff particle
-- 	self:AddParticle(
-- 		nFXIndex,
-- 		bDestroyImmediately,
-- 		bStatusEffect,
-- 		iPriority,
-- 		bHeroEffect,
-- 		bOverheadEffect
-- 	)

-- 	-- Create Sound
-- 	EmitSoundOnLocationWithCaster( vTargetPosition, sound_location, self:GetCaster() )
-- 	EmitSoundOn( sound_target, target )
-- end

modifier_enchantress_enchant_lua_slow = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_enchantress_enchant_lua_slow:IsHidden()
	return false
end

function modifier_enchantress_enchant_lua_slow:IsDebuff()
	return true
end

function modifier_enchantress_enchant_lua_slow:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_enchantress_enchant_lua_slow:OnCreated( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed" ) -- special value
end

function modifier_enchantress_enchant_lua_slow:OnRefresh( kv )
	-- references
	self.slow = self:GetAbility():GetSpecialValueFor( "slow_movement_speed" ) -- special value
end

function modifier_enchantress_enchant_lua_slow:OnDestroy( kv )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_enchantress_enchant_lua_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end
function modifier_enchantress_enchant_lua_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_enchantress_enchant_lua_slow:GetEffectName()
	return "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf"
end

function modifier_enchantress_enchant_lua_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end