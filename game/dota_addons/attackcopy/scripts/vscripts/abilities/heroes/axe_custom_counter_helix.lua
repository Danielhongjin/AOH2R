axe_custom_counter_helix = class({})
LinkLuaModifier( "modifier_axe_custom_counter_helix", "abilities/heroes/axe_custom_counter_helix.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
-- Passive Modifier
function axe_custom_counter_helix:GetIntrinsicModifierName()
	return "modifier_axe_custom_counter_helix"
end

modifier_axe_custom_counter_helix = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_custom_counter_helix:IsHidden()
	return true
end

function modifier_axe_custom_counter_helix:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
	function modifier_axe_custom_counter_helix:OnCreated( kv )
		-- references
		self.ability = self:GetAbility()
		self.radius = self.ability:GetSpecialValueFor( "radius" )
		self.chance = self.ability:GetSpecialValueFor( "trigger_chance" ) + 1
		self.hpRatio = self.ability:GetSpecialValueFor( "health_ratio" ) * 0.01
		self.hasTalent = false
		self.parent = self:GetParent()
		self.teamNumber = self.parent:GetTeamNumber()
		
		self.damage = 0
		local think_interval = 3
		self:StartIntervalThink(think_interval)
		if IsServer() then
			self.baseDamage = self.ability:GetAbilityDamage()

			self.damageTable = {
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self.ability, --Optional.
				damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			}
		end
		
	end
if IsServer() then
	function modifier_axe_custom_counter_helix:OnIntervalThink()
		if not self.hasTalent then
			local talent = self.parent:FindAbilityByName("special_bonus_unique_axe_3")
			if talent and talent:GetLevel() > 0 then
				self.hasTalent = true
				self:StartIntervalThink(-1)
			end
		end
	end
end

function modifier_axe_custom_counter_helix:OnRefresh( kv )
	if IsServer() then
		self.baseDamage = self.ability:GetAbilityDamage()
	end
end

function modifier_axe_custom_counter_helix:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_custom_counter_helix:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_axe_custom_counter_helix:OnAttackLanded( params )
	if IsServer() then
		if params.target == self:GetCaster() or params.attacker == self:GetCaster() and self.hasTalent then
			if self.ability:IsCooldownReady() then
				-- roll dice
				if RandomInt(1,100)>self.chance then return end
				self.damage = self.baseDamage + self.parent:GetMaxHealth() * self.hpRatio
				-- find enemies
				local enemies = FindUnitsInRadius(
					self.teamNumber,	-- int, your team number
					self.parent:GetOrigin(),	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
					DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
					0,	-- int, order filter
					false	-- bool, can grow cache
				)
				
				-- damage
				for _,enemy in pairs(enemies) do
					self.damageTable.damage =  self.damage / #enemies
					self.damageTable.victim = enemy
					ApplyDamage( self.damageTable )
				end

				-- cooldown
				self.ability:UseResources( false, false, true )

				-- effects
				self:PlayEffects()
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_custom_counter_helix:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_axe/axe_counterhelix.vpcf"
	local sound_cast = "Hero_Axe.CounterHelix"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:ReleaseParticleIndex( effect_cast )
	local effect_cast2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:ReleaseParticleIndex( effect_cast2 )
	

	-- Create Sound
	EmitSoundOn( sound_cast, self:GetParent() )
end

