LinkLuaModifier("modifier_boss_legion_commander_bunker", "abilities/bosses/boss_legion_commander_bunker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boss_legion_commander_summon", "abilities/bosses/boss_legion_commander_bunker.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/timers")
boss_legion_commander_bunker = class({})


function boss_legion_commander_bunker:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	caster:Stop()
	Timers:CreateTimer(
		0, 
		function()
			if caster:HasModifier("modifier_boss_legion_commander_warpath") then
				return 0.5
			end
			StartAnimation(caster, {duration = delay, activity = ACT_DOTA_CAST_ABILITY_4, rate = 1 / delay})
			caster:AddNewModifier(caster, self, "modifier_anim", {duration = delay})
			Timers:CreateTimer(
				delay, 
				function()
					caster:AddNewModifier(caster, self, "modifier_boss_legion_commander_bunker", {duration = self:GetSpecialValueFor("duration")})
				end
			)
		end
	)
	
		
	
end

modifier_boss_legion_commander_bunker = class({})

function modifier_boss_legion_commander_bunker:IsPurgable()
	return true
end

function modifier_boss_legion_commander_bunker:IsHidden()
	return false
end


function modifier_boss_legion_commander_bunker:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_boss_legion_commander_bunker:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
	}
	return state
end


function modifier_boss_legion_commander_bunker:GetModifierIncomingDamage_Percentage()
    return self:GetAbility():GetSpecialValueFor("damage_reduction_percent")
end

function modifier_boss_legion_commander_bunker:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("hp_regen")
end

if IsServer() then
	function modifier_boss_legion_commander_bunker:OnCreated(keys)
		self.parent = self:GetParent()
		local ability = self:GetAbility()
		self.arrow_delay = ability:GetSpecialValueFor("arrow_delay")
		self.arrow_radius = ability:GetSpecialValueFor("arrow_radius")
		self.arrow_spread = ability:GetSpecialValueFor("arrow_spread")
		self.arrow_count = ability:GetSpecialValueFor("arrow_count")
		self.damageTable = {
			-- victim = target,
			attacker = self.parent,
			damage =  ability:GetSpecialValueFor("arrow_damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability, --Optional.
		}
		self.parent:EmitSound("Hero_LegionCommander.PressTheAttack")
		self.anim = self.parent:AddNewModifier(self.parent, ability, "modifier_anim", {duration = -1})
		StartAnimation(self.parent, {duration=500, activity=ACT_DOTA_DISABLED, rate=1})
		self.knight1 = CreateUnitByName("npc_dragon_knight", self.parent:GetAbsOrigin(), true, self.parent, self.parent, self.parent:GetTeamNumber())
		FindClearSpaceForUnit(self.knight1, self.parent:GetAbsOrigin() + Vector(200, 0, 0), true)
		self.knight1:AddNewModifier(self.parent, ability, "modifier_boss_legion_commander_summon", {duration = -1})
		
		self.knight2 = CreateUnitByName("npc_dragon_knight", self.parent:GetAbsOrigin(), true, self.parent, self.parent, self.parent:GetTeamNumber())
		FindClearSpaceForUnit(self.knight2, self.parent:GetAbsOrigin() + Vector(-100, -174, 0), true)
		self.knight2:AddNewModifier(self.parent, ability, "modifier_boss_legion_commander_summon", {duration = -1})
		
		self.knight3 = CreateUnitByName("npc_dragon_knight", self.parent:GetAbsOrigin(), true, self.parent, self.parent, self.parent:GetTeamNumber())
		FindClearSpaceForUnit(self.knight3, self.parent:GetAbsOrigin() + Vector(-100, 174, 0), true)
		self.knight3:AddNewModifier(self.parent, ability, "modifier_boss_legion_commander_summon", {duration = -1})
		
		self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_duel_ring.vpcf", PATTACH_ABSORIGIN, self.parent)
		ParticleManager:SetParticleControl(self.fx, 0, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.fx, 7, self.parent:GetAbsOrigin())
		
		self.fx2 = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shield.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		
		self.parent:Stop()
		
		self:StartIntervalThink(0.5)
	end
	
	function modifier_boss_legion_commander_bunker:OnAttacked(keys)
		local attacker = keys.attacker
		local victim = keys.target
		if self.parent == victim then
			EmitSoundOn("Hero_Mars.Spear.Cast", caster)
			local position = attacker:GetAbsOrigin()
			local caster_pos = self.parent:GetAbsOrigin()
			local count = 1
			Timers:CreateTimer(
				0, 
				function()
					local pos = position + Vector(RandomInt(-self.arrow_spread, self.arrow_spread), RandomInt(-self.arrow_spread, self.arrow_spread), 0)
					local fx = ParticleManager:CreateParticle("particles/custom/aoe_warning.vpcf", PATTACH_WORLDORIGIN, self.parent)
					ParticleManager:SetParticleControl(fx, 0, pos)
					ParticleManager:SetParticleControl(fx, 1, Vector(self.arrow_radius, 1, 1))
					ParticleManager:SetParticleControl(fx, 2, Vector(self.arrow_delay, 1, 1))
					ParticleManager:SetParticleControl(fx, 3, Vector(200, 10, 10))
					ParticleManager:ReleaseParticleIndex(fx)
					local fx = ParticleManager:CreateParticle("particles/custom/custom_odds_arrow_start_pos.vpcf", PATTACH_WORLDORIGIN, self.parent)
					ParticleManager:SetParticleControl(fx, 0, pos)
					ParticleManager:SetParticleControl(fx, 1, caster_pos)
					ParticleManager:SetParticleControl(fx, 9, Vector(self.arrow_delay, 0, 0))
					ParticleManager:ReleaseParticleIndex(fx)
					self.parent:EmitSound("Hero_Mars.Shield.Block")
					
					Timers:CreateTimer(
						self.arrow_delay, 
						function()
							
							EmitSoundOnLocationWithCaster(pos, "Hero_LegionCommander.Overwhelming.Creep", attacker)
							local enemies = FindUnitsInRadius(
								self.parent:GetTeamNumber(),	-- int, your team number
								pos,	-- point, center point
								nil,	-- handle, cacheUnit. (not known)
								self.arrow_radius,	-- float, 	radius. or use FIND_UNITS_EVERYWHERE
								DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
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
					if count < self.arrow_count then
						count = count + 1
						return 0.1
					end
				end
			)

		end
	end
	
	function modifier_boss_legion_commander_bunker:OnIntervalThink()
		if (self.knight1:IsNull() or not self.knight1:IsAlive()) and (self.knight2:IsNull() or not self.knight2:IsAlive()) and (self.knight3:IsNull() or not self.knight3:IsAlive()) then
			self:Destroy()
		end
	end	
	
	function modifier_boss_legion_commander_bunker:OnDestroy()
		EndAnimation(self.parent)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
		ParticleManager:DestroyParticle(self.fx2, true)
		ParticleManager:ReleaseParticleIndex(self.fx2)
		if self.anim then
			self.anim:Destroy()
		end
		self.parent:SetCursorCastTarget(self.parent)
		self.parent:FindAbilityByName("boss_legion_commander_press_the_attack"):OnSpellStart()
	end
end

modifier_boss_legion_commander_summon = class({})

function modifier_boss_legion_commander_summon:IsPurgable()
	return true
end

function modifier_boss_legion_commander_summon:IsHidden()
	return false
end

if IsServer() then
	function modifier_boss_legion_commander_summon:OnCreated(keys)
		self.parent = self:GetParent()
		self.caster = self:GetCaster()
		self.fx = ParticleManager:CreateParticle("particles/custom/link_positive.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.fx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
		self.degen = self:GetAbility():GetSpecialValueFor("summon_degen") / 100
		self.range = self:GetAbility():GetSpecialValueFor("summon_range")
		self.health = self.caster:GetMaxHealth()
		self.interval = 0.25
		self:StartIntervalThink(self.interval)
	end
	
	function modifier_boss_legion_commander_summon:OnIntervalThink()
		if CalcDistanceBetweenEntityOBB(self.caster, self.parent) > self.range then
			ParticleManager:CreateParticle("particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_soft.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ApplyDamage({
				victim = self.parent,
				attacker = self.caster,
				damage = self.health * self.degen * self.interval,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
				ability = self.ability
			})
		end
	end	
	
	function modifier_boss_legion_commander_summon:OnDestroy()
		self.parent:CastAbilityOnTarget(self.parent, self.parent:FindAbilityByName("boss_legion_commander_press_the_attack"), -1)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
	end
end