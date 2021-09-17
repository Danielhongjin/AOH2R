LinkLuaModifier( "modifier_storm_sigil_behavior", "abilities/bosses/boss_storm_spirit_sigil.lua", LUA_MODIFIER_MOTION_NONE )
boss_storm_spirit_sigil = class({})


function boss_storm_spirit_sigil:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local sigil = CreateUnitByName("npc_storm_sigil", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	sigil:SetForceAttackTarget(target)
	sigil:AddNewModifier(
		target,
		self,
		"modifier_storm_sigil_behavior", -- modifier name
		{duration = self:GetSpecialValueFor("duration") } -- kv
	)
end

void_spirit_temp_ability = class(boss_storm_spirit_sigil)
modifier_storm_sigil_behavior = class({})

function modifier_storm_sigil_behavior:IsPurgable()
	return false
end

function modifier_storm_sigil_behavior:IsHidden()
	return false
end

function modifier_storm_sigil_behavior:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

if IsServer() then
	function modifier_storm_sigil_behavior:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.target = self:GetCaster()
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.delay = self.ability:GetSpecialValueFor("delay")
		self.lightning_radius = self.ability:GetSpecialValueFor("lightning_radius")
		if self.ability:GetAbilityName() == "void_spirit_temp_ability" then
			self.create_warnings = false
		end
		if self.create_warnings == true then
			self.fx = ParticleManager:CreateParticle("particles/custom/bear_maul.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
			self.create_warnings = true
			
			ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(self.fx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.fx, 2, Vector(self:GetAbility():GetSpecialValueFor("duration"), 1, 0))
			self.fx2 = ParticleManager:CreateParticle("particles/custom/follow_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(self.fx2, 1, Vector(self.lightning_radius, 1, 1))
		end
		
		
		
		self.damageTable = {
			-- victim = target,
			attacker = self.parent,
			damage =  self.ability:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability, --Optional.
		}
		self:StartIntervalThink(self.interval)
	end
	
	
	function modifier_storm_sigil_behavior:OnIntervalThink()
		local pos = self.parent:GetAbsOrigin() + Vector(RandomInt(-self.lightning_radius, self.lightning_radius), RandomInt(-self.lightning_radius, self.lightning_radius))
		if self.create_warnings == true then
			local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
			ParticleManager:SetParticleControl(fx, 0, pos)
			ParticleManager:SetParticleControl(fx, 1, Vector(self.radius, 1, 1))
			ParticleManager:SetParticleControl(fx, 2, Vector(self.delay, 1, 1))
			ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
			ParticleManager:ReleaseParticleIndex(fx)
		end
		Timers:CreateTimer(
			self.delay, 
			function()
				self.parent:EmitSoundParams("Hero_Leshrac.Lightning_Storm", 0, 0.4, 0)
				local particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, self.parent)
				ParticleManager:SetParticleControl(particleIndex, 0, pos + Vector(0, 0, 1000))
				ParticleManager:SetParticleControl(particleIndex, 1, pos)
				ParticleManager:SetParticleControl(particleIndex, 2, pos)
				ParticleManager:ReleaseParticleIndex(particleIndex)
				local enemies = FindUnitsInRadius(
					self.parent:GetTeamNumber(),	-- int, your team number
					pos,	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					self.radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
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
	
	function modifier_storm_sigil_behavior:OnDestroy()
		if self.create_warnings == true then
			ParticleManager:DestroyParticle(self.fx, true)
			ParticleManager:ReleaseParticleIndex(self.fx)
			ParticleManager:DestroyParticle(self.fx2, true)
			ParticleManager:ReleaseParticleIndex(self.fx2)
		end
		self.parent:ForceKill(false)
	end
end