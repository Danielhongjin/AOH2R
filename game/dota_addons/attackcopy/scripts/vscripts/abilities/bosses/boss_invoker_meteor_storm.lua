require("lib/timers")
require("lib/my")
require("lib/ai")
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
boss_invoker_meteor_storm = class({})

function boss_invoker_meteor_storm:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local position = target:GetAbsOrigin()
	local caster_origin = caster:GetAbsOrigin()
	local delay = self:GetSpecialValueFor("delay")
	local total = self:GetSpecialValueFor("count")
	total = total + math.floor(5 * (math.abs(caster:GetHealthPercent() - 100) * 0.01))
	print(total)
	local spread = self:GetSpecialValueFor("spread")
	spread = spread + math.floor(100 * (math.abs(caster:GetHealthPercent() - 100) * 0.01))
	local count = 1
	local radius = self:GetSpecialValueFor("area_of_effect")
	local distance = self:GetSpecialValueFor("travel_distance")
	local land_time = self:GetSpecialValueFor("land_time")
	local exort = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_apex_exort_orb.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(exort, 1, caster:GetAbsOrigin() + Vector(0, 0, 400))
	caster:AddNewModifier(caster, ability, "modifier_anim", {duration = total * 0.2})
	Timers:CreateTimer(
		0, 
		function()
			local pos = position + Vector(RandomInt(-spread, spread), RandomInt(-spread, spread), 0)
			caster:FaceTowards(pos)
			CreateModifierThinker(
				caster, -- player source
				self, -- ability source
				"modifier_invoker_chaos_meteor_lua_thinker", -- modifier name
				{}, -- kv
				pos,
				caster:GetTeamNumber(),
				false
			)
			
			local forward_vector = (Vector(pos.x, pos.y, 0) - Vector(caster_origin.x, caster_origin.y, 0)):Normalized()
			local end_pos = forward_vector * distance + caster_origin
			local fx = ParticleManager:CreateParticle("particles/custom/line_aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, caster_origin)
			ParticleManager:SetParticleControl(fx, 1, pos)
			ParticleManager:SetParticleControl(fx, 2, end_pos)
			ParticleManager:SetParticleControl(fx, 3, Vector(radius, radius, 1))
			ParticleManager:SetParticleControl(fx, 4, Vector(delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx)
			
			local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(fx, 0, pos)
			ParticleManager:SetParticleControl(fx, 1, Vector(radius, 1, 1))
			ParticleManager:SetParticleControl(fx, 2, Vector(delay, 1, 1))
			ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
			ParticleManager:ReleaseParticleIndex(fx)
			
			local fx2 = ParticleManager:CreateParticle("particles/custom/link_warning.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(fx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_origin, true)
			ParticleManager:SetParticleControl(fx2, 1, pos)
			ParticleManager:SetParticleControl(fx2, 2, Vector(delay, 1, 1))
			ParticleManager:ReleaseParticleIndex(fx2)
			if count < total then
				count = count + 1
				return 0.2
			end
		end
	)
	Timers:CreateTimer(
		2, 
		function()
			ParticleManager:DestroyParticle(exort, true)
			ParticleManager:ReleaseParticleIndex(exort)
		end
	)
end

LinkLuaModifier( "modifier_invoker_chaos_meteor_lua_thinker", "abilities/bosses/boss_invoker_meteor_storm.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_invoker_chaos_meteor_lua_burn", "abilities/bosses/boss_invoker_meteor_storm.lua", LUA_MODIFIER_MOTION_NONE )

modifier_invoker_chaos_meteor_lua_burn = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_chaos_meteor_lua_burn:IsHidden()
	return false
end

function modifier_invoker_chaos_meteor_lua_burn:IsDebuff()
	return true
end

function modifier_invoker_chaos_meteor_lua_burn:IsStunDebuff()
	return false
end

function modifier_invoker_chaos_meteor_lua_burn:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_invoker_chaos_meteor_lua_burn:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_invoker_chaos_meteor_lua_burn:OnCreated( kv )
	if IsServer() then
		-- references
		local damage = self:GetAbility():GetSpecialValueFor("burn_dps")
		local delay = 1
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		-- Start interval
		self:StartIntervalThink( delay )
	end
end

function modifier_invoker_chaos_meteor_lua_burn:OnRefresh( kv )
	
end

function modifier_invoker_chaos_meteor_lua_burn:OnDestroy( kv )

end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_invoker_chaos_meteor_lua_burn:OnIntervalThink()
	-- damage
	ApplyDamage( self.damageTable )

	-- play effects
	local sound_tick = "Hero_Invoker.ChaosMeteor.Damage"
	EmitSoundOn( sound_tick, self:GetParent() )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_invoker_chaos_meteor_lua_burn:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_invoker_chaos_meteor_lua_burn:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_invoker_chaos_meteor_lua_thinker = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_chaos_meteor_lua_thinker:IsHidden()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_invoker_chaos_meteor_lua_thinker:OnCreated( kv )
	if IsServer() then
		-- references
		self.caster_origin = self:GetCaster():GetOrigin()
		self.parent_origin = self:GetParent():GetOrigin()
		self.direction = self.parent_origin - self.caster_origin
		self.direction.z = 0
		self.direction = self.direction:Normalized()

		self.delay = self:GetAbility():GetSpecialValueFor( "land_time" )
		self.radius = self:GetAbility():GetSpecialValueFor( "area_of_effect" )
		self.distance = self:GetAbility():GetSpecialValueFor( "travel_distance" )
		self.speed = self:GetAbility():GetSpecialValueFor( "travel_speed" )
		self.vision = self:GetAbility():GetSpecialValueFor( "vision_distance" )
		self.vision_duration = self:GetAbility():GetSpecialValueFor( "end_vision_duration" )
		
		self.interval = self:GetAbility():GetSpecialValueFor( "damage_interval" )
		self.duration = self:GetAbility():GetSpecialValueFor( "burn_duration" )
		local damage = self:GetAbility():GetSpecialValueFor( "main_damage" )

		-- variables
		self.fallen = false
		self.damageTable = {
			-- victim = target,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		-- vision
		self:GetParent():SetDayTimeVisionRange( self.vision )
		self:GetParent():SetNightTimeVisionRange( self.vision )

		-- Start interval
		self:StartIntervalThink( self.delay )

		-- play effects
		self:PlayEffects1()
	end
end

function modifier_invoker_chaos_meteor_lua_thinker:OnRefresh( kv )
	
end

function modifier_invoker_chaos_meteor_lua_thinker:OnDestroy( kv )
	if IsServer() then
		-- add vision
		AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.vision, self.vision_duration, false)

		-- stop effects
		local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"
		local sound_stop = "Hero_Invoker.ChaosMeteor.Destroy"
		StopSoundOn( sound_loop, self:GetParent() )
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_stop, self:GetCaster() )
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_invoker_chaos_meteor_lua_thinker:OnIntervalThink()
	if not self.fallen then
		-- meatball has fallen
		self.fallen = true
		self:StartIntervalThink( self.interval )
		self:Burn()
		
		self:PlayEffects2()
	else
		-- move & damages
		self:Move_Burn()
	end
end

function modifier_invoker_chaos_meteor_lua_thinker:Burn()
	-- find enemies
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		-- apply damage
		self.damageTable.victim = enemy
		ApplyDamage( self.damageTable )

		-- add modifier
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_invoker_chaos_meteor_lua_burn", -- modifier name
			{ duration = self.duration } -- kv
		)
	end
end

--------------------------------------------------------------------------------
-- Motion effects
function modifier_invoker_chaos_meteor_lua_thinker:Move_Burn()
	local parent = self:GetParent()

	-- set position
	local target = self.direction*self.speed*self.interval
	parent:SetOrigin( parent:GetOrigin() + target )

	-- Burn
	self:Burn()
	
	-- check distance for next step
	if (parent:GetOrigin() - self.parent_origin + target):Length2D()>self.distance then
		self:Destroy()
		return
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_invoker_chaos_meteor_lua_thinker:PlayEffects1()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf"
	local sound_impact = "Hero_Invoker.ChaosMeteor.Cast"

	-- Get Data
	local height = 1000
	local height_target = -0

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( effect_cast, 0, self.caster_origin + Vector( 0, 0, height ) )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent_origin + Vector( 0, 0, height_target) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Create Sound
	EmitSoundOnLocationWithCaster( self.caster_origin, sound_impact, self:GetCaster() )
end

function modifier_invoker_chaos_meteor_lua_thinker:PlayEffects2()
	-- Get Resources
	local particle_cast = "particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf"
	local sound_impact = "Hero_Invoker.ChaosMeteor.Impact"
	local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"

	-- Create Particle
	-- local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent_origin )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self.direction )
	ParticleManager:SetParticleControl( effect_cast, 1, self.direction * self.speed )
	-- ParticleManager:ReleaseParticleIndex( effect_cast )

	-- -- buff particle
	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	-- Create Sound
	EmitSoundOnLocationWithCaster( self.parent_origin, sound_impact, self:GetCaster() )
	EmitSoundOn( sound_loop, self:GetParent() )
end