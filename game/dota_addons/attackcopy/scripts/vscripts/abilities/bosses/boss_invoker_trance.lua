LinkLuaModifier("modifier_boss_invoker_trance", "abilities/bosses/boss_invoker_trance.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_anim", "abilities/other/generic.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/timers")
boss_invoker_trance = class({})


function boss_invoker_trance:OnSpellStart()
	local caster = self:GetCaster()
	local delay = self:GetSpecialValueFor("delay")
	caster:AddNewModifier(caster, self, "modifier_boss_invoker_trance", {duration = self:GetSpecialValueFor("duration")})
	
		
	
end

modifier_boss_invoker_trance = class({})

function modifier_boss_invoker_trance:IsPurgable()
	return true
end

function modifier_boss_invoker_trance:IsHidden()
	return false
end


function modifier_boss_invoker_trance:DeclareFunctions()
        return {
            MODIFIER_PROPERTY_REFLECT_SPELL,
        }
    end

function modifier_boss_invoker_trance:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}
	return state
end

function modifier_boss_invoker_trance:GetReflectSpell(keys)
        local parent = self:GetParent()
        local time = GameRules:GetGameTime()
        local usedAbility = keys.ability
        local usedAbilityName = usedAbility:GetName()
        local usedAbilityCaster = usedAbility:GetCaster()
        if usedAbilityCaster:GetTeamNumber() == parent:GetTeamNumber() or usedAbility.isReflection or usedAbility:GetChannelTime() > 0 then
            return
        end
        local ability = parent:FindAbilityByName(usedAbilityName)
        if not ability then -- spell was never reflected
            ability = parent:AddAbility(usedAbilityName)
            ability:SetStolen(true)
            ability:SetHidden(true)
            ability:SetLevel(usedAbility:GetLevel())
            ability.isReflection = true
        end
        parent:SetCursorCastTarget(usedAbilityCaster)
        ability:OnSpellStart()
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(particle, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
        ParticleManager:ReleaseParticleIndex(particle)
        parent:EmitSound("Hero_Antimage.SpellShield.Reflect")
    end

if IsServer() then
	function modifier_boss_invoker_trance:OnCreated(keys)
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.radius = self.ability:GetSpecialValueFor("radius")
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.ticket_concession = self.parent:FindModifierByName("modifier_boss")
		self.ticket_concession:Lockout()
		self.damageTable = {
			-- victim = target,
			attacker = self.parent,
			damage =  self.ability:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability, --Optional.
		}
		self.parent:AddNewModifier(self.parent, ability, "modifier_anim", {duration = self.ability:GetSpecialValueFor("duration") - 1})
		StartAnimation(self.parent, {duration=5000, activity=ACT_DOTA_DISABLED, rate=1})
		self.parent:Stop()

		self.fx = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shield.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControlEnt(self.fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		
		self.fx2 = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_apex_quas_orb.vpcf", PATTACH_POINT, self.parent)
		ParticleManager:SetParticleControl(self.fx2, 1, self.parent:GetAbsOrigin() + Vector(0, 0, 400))
		self:StartIntervalThink(self.interval)
	end
	

	function modifier_boss_invoker_trance:OnIntervalThink()
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
		local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT, self.parent)
		if #enemies == 0 then
			self.parent:EmitSoundParams("Hero_Zuus.ArcLightning.Cast", 0, 0.25, 0)
			local pos = self.parent:GetAbsOrigin() + Vector(RandomInt(-self.radius, self.radius), RandomInt(-self.radius, self.radius), RandomInt(0, 350))
			ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(fx, 1, pos)
			
		else
			for _, enemy in ipairs(enemies) do
				self.parent:EmitSoundParams("Hero_Zuus.ArcLightning.Target", 0, 0.4, 0)
				ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(fx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				self.damageTable.victim = enemy
				ApplyDamage(self.damageTable)
				break
			end
		end
		ParticleManager:ReleaseParticleIndex(fx)
	end	
	
	function modifier_boss_invoker_trance:OnDestroy()
		self.ticket_concession:ReleaseLockout()
		EndAnimation(self.parent)
		ParticleManager:DestroyParticle(self.fx, true)
		ParticleManager:ReleaseParticleIndex(self.fx)
		ParticleManager:DestroyParticle(self.fx2, true)
		ParticleManager:ReleaseParticleIndex(self.fx2)
	end
end
