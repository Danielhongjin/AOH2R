LinkLuaModifier("modifier_boss_legion_commander_warpath", "abilities/bosses/boss_legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_legion_commander_warpath_attack", "abilities/bosses/boss_legion_commander_warpath.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/timers")
boss_legion_commander_warpath = class({})

function boss_legion_commander_warpath:OnSpellStart()
	local caster = self:GetCaster()
	Timers:CreateTimer(
		0, 
		function()
			if caster:HasModifier("modifier_boss_legion_commander_bunker") then
				return 0.5
			end
			caster:AddNewModifier(caster, self, "modifier_boss_legion_commander_warpath", {duration = self:GetSpecialValueFor("duration")})
			caster:AddNewModifier(caster, self, "modifier_boss_legion_commander_warpath_attack", {duration = self:GetSpecialValueFor("duration")})
		end
	) 
	
end

modifier_boss_legion_commander_warpath = class({})

function modifier_boss_legion_commander_warpath:IsPurgable()
	return true
end

function modifier_boss_legion_commander_warpath:IsHidden()
	return false
end

function modifier_boss_legion_commander_warpath:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
    }
end

function modifier_boss_legion_commander_warpath:GetModifierMoveSpeed_AbsoluteMin()
    return self:GetAbility():GetSpecialValueFor("minimum_movespeed")
end



function modifier_boss_legion_commander_warpath:GetStatusEffectName()
	return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf"
end

if IsServer() then
	function modifier_boss_legion_commander_warpath:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.delay = ability:GetSpecialValueFor("delay")
		self.explosion_radius = ability:GetSpecialValueFor("explosion_radius")
		self.parent:EmitSound("Hero_LegionCommander.Duel.Cast")
		self.parent:EmitSound("Hero_LegionCommander.Duel.FP")
		self.explosion_interval = ability:GetSpecialValueFor("explosion_interval")
		self.damageTable = {
			attacker = self.parent,
			damage =  ability:GetSpecialValueFor("explosion_damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability,
		}
		self.fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_doom_bringer/doom_scorched_earth.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControl(self.fx, 1, Vector(500, 0, 0))
		self:StartIntervalThink(self.explosion_interval)
	end
	
	function modifier_boss_legion_commander_warpath:OnIntervalThink()
		local pos = self.parent:GetAbsOrigin()
		Timers:CreateTimer(
			0, 
			function()
				local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
				ParticleManager:SetParticleControl(fx, 0, pos)
				ParticleManager:SetParticleControl(fx, 1, Vector(self.explosion_radius, 1, 1))
				ParticleManager:SetParticleControl(fx, 2, Vector(self.delay, 1, 1))
				ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
				ParticleManager:ReleaseParticleIndex(fx)
				Timers:CreateTimer(
					self.delay, 
					function()
						self.parent:EmitSound("Ability.LightStrikeArray")
						local fx = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN, nil )
						ParticleManager:SetParticleControl(fx, 0, pos)
						ParticleManager:SetParticleControl(fx, 1, Vector(self.explosion_radius, 1, 1))
						ParticleManager:ReleaseParticleIndex(fx)

						local enemies = FindUnitsInRadius(
							self.parent:GetTeamNumber(),	-- int, your team number
							pos,	-- point, center point
							nil,	-- handle, cacheUnit. (not known)
							self.explosion_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
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
						end
					end
				)
			end
		)
	end	
	function modifier_boss_legion_commander_warpath:OnDestroy(keys)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end

modifier_boss_legion_commander_warpath_attack = class({})

function modifier_boss_legion_commander_warpath_attack:IsPurgable()
	return true
end

function modifier_boss_legion_commander_warpath_attack:IsHidden()
	return false
end

function modifier_boss_legion_commander_warpath_attack:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end

if IsServer() then
	function modifier_boss_legion_commander_warpath_attack:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.radius = ability:GetSpecialValueFor("rebuke_radius")
		self.interval = ability:GetSpecialValueFor("rebuke_interval")
		self.rebuke = self.parent:FindAbilityByName("boss_legion_commander_gods_rebuke_wrapper")
		self.rebuke:EndCooldown()
		self:StartIntervalThink(self.interval)
	end
	
	function modifier_boss_legion_commander_warpath_attack:OnIntervalThink()
		if self.rebuke:IsCooldownReady() then
			local units = FindUnitsInRadius(self.parent:GetTeam(), 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			0, 
			false)
        
			for _, unit in ipairs(units) do
				if unit then
					self.parent:SetCursorCastTarget(unit)
					self.rebuke:OnSpellStart()
					self.rebuke:StartCooldown(1.25)
					break
				end
				
			end
		end
	end	
end