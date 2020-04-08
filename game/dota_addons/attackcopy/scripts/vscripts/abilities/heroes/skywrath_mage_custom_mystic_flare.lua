skywrath_mage_custom_mystic_flare = class({})


--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function skywrath_mage_custom_mystic_flare:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------
-- Ability Start
function skywrath_mage_custom_mystic_flare:OnSpellStart()
	-- unit identifier
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	-- load data
	local duration = self:GetSpecialValueFor( "duration" )
	local radius = self:GetSpecialValueFor( "radius" )

	-- create thinker
	CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_skywrath_mage_custom_mystic_flare_thinker", -- modifier name
		{ duration = duration }, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)

	-- play effects
	local sound_cast = "Hero_SkywrathMage.MysticFlare.Cast"
	EmitSoundOn( sound_cast, caster )

	-- scepter effect
	if caster:HasScepter() then
		local scepter_radius = self:GetSpecialValueFor( "scepter_radius" )
		
		-- find nearby enemies
		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			point,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			scepter_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		local target = nil
		local creep = nil
		-- prioritize hero
		for _,enemy in pairs(enemies) do
			-- only enemies outside cast aoe
			if (enemy:GetOrigin()-point):Length2D()>radius then
				if enemy:IsHero() then
					target = enemy
					break
				elseif not creep then
					-- store first found creep
					creep = enemy
				end
			end
		end
		-- no secondary hero found, find creep
		if not target then
			target = creep
		end

		if target then
			-- create thinker
			CreateModifierThinker(
				caster, -- player source
				self, -- ability source
				"modifier_skywrath_mage_custom_mystic_flare_thinker", -- modifier name
				{ duration = duration }, -- kv
				target:GetOrigin(),
				caster:GetTeamNumber(),
				false
			)
		end
	end
end
LinkLuaModifier( "modifier_skywrath_mage_custom_mystic_flare_thinker", "abilities/heroes/skywrath_mage_custom_mystic_flare", LUA_MODIFIER_MOTION_NONE )
modifier_skywrath_mage_custom_mystic_flare_thinker = class({})

--------------------------------------------------------------------------------
-- Initializations
function modifier_skywrath_mage_custom_mystic_flare_thinker:OnCreated( kv )
	-- references
	local interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
	self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	
	if IsServer() then
		-- precache damage
		local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_skywrath_5")

    if talent and talent:GetLevel() > 0 then
        self.damage = self.damage + talent:GetSpecialValueFor("value")
    end
		self.damage = self.damage*interval/kv.duration
		self.damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			-- damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
			-- damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
		}

		-- Start interval
		self:StartIntervalThink( interval )
		self:OnIntervalThink()

		-- play effects
		self:PlayEffects( self.radius, kv.duration, interval )
	end
end

function modifier_skywrath_mage_custom_mystic_flare_thinker:OnRemoved()
end

function modifier_skywrath_mage_custom_mystic_flare_thinker:OnDestroy()
	if IsServer() then
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_skywrath_mage_custom_mystic_flare_thinker:OnIntervalThink()
	-- find heroes
	local heroes = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	if #heroes<1 then return end
	for _,hero in pairs(heroes) do
		self.damageTable.victim = hero
		self.damageTable.damage = self.damage/#heroes
		ApplyDamage( self.damageTable )
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_skywrath_mage_custom_mystic_flare_thinker:PlayEffects( radius, duration, interval )
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf"
	local sound_cast = "Hero_SkywrathMage.MysticFlare"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, duration, interval ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end