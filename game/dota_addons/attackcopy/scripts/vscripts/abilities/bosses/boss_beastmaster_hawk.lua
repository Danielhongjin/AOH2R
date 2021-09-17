LinkLuaModifier( "modifier_hawk_behavior", "abilities/bosses/boss_beastmaster_hawk.lua", LUA_MODIFIER_MOTION_NONE )
boss_beastmaster_hawk = class({})


function boss_beastmaster_hawk:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local hawk = CreateUnitByName("npc_boss_hawk", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeam())
	hawk:AddNewModifier(
		target,
		self,
		"modifier_hawk_behavior", -- modifier name
		{duration = self:GetSpecialValueFor("duration") } -- kv
	)
end

modifier_hawk_behavior = class({})

function modifier_hawk_behavior:IsPurgable()
	return false
end

function modifier_hawk_behavior:IsHidden()
	return false
end

function modifier_hawk_behavior:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
	return state
end

if IsServer() then
	function modifier_hawk_behavior:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.target = self:GetCaster()
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.fx = ParticleManager:CreateParticle("particles/custom/follow_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(self.fx, 1, Vector(self.radius, 1, 1))
		self.damageTable = {
			-- victim = target,
			attacker = self.parent,
			damage =  self.ability:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability, --Optional.
		}
		self:StartIntervalThink(self.interval)
	end
	
	
	function modifier_hawk_behavior:OnIntervalThink()
		self.parent:MoveToNPC(self.target)
		local enemies = FindUnitsInRadius(
			self.parent:GetTeamNumber(),	-- int, your team number
			self.parent:GetAbsOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			self.radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			self.parent:EmitSoundParams("Hero_Zuus.ArcLightning.Target", 0, 0.5, 0)
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT, self.parent)
			ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			self.damageTable.victim = enemy
			ApplyDamage( self.damageTable )
			break
		end
			
	end	
	
	function modifier_hawk_behavior:OnDestroy()
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
		self.parent:ForceKill(false)
	end
end