huskar_custom_life_break = class({})


function huskar_custom_life_break:OnSpellStart()
	local caster = self:GetCaster()
	if caster:HasAbility("special_bonus_unique_huskar") then
		local talent = caster:FindAbilityByName("special_bonus_unique_huskar")
		if talent and talent:GetLevel() > 0 then
			caster:AddNewModifier(
				caster,
				self,
				"modifier_huskar_talent1", -- modifier name
				{} -- kv
			)
		end
	end
	self.modifier = caster:AddNewModifier(
		caster,
		self,
		"modifier_huskar_custom_life_break", -- modifier name
		{ duration = self:GetChannelTime() } -- kv
	)
	
end

function huskar_custom_life_break:GetChannelTime()
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_huskar_talent1") then
		return self.BaseClass.GetChannelTime(self) + 5
	end
    return self.BaseClass.GetChannelTime(self)
end

function huskar_custom_life_break:OnChannelFinish( bInterrupted )
	if self.modifier then
		self.modifier:Destroy()
		self.modifier = nil
	end
end


LinkLuaModifier("modifier_huskar_custom_life_break", "abilities/heroes/huskar_custom_life_break.lua", LUA_MODIFIER_MOTION_NONE)
modifier_huskar_custom_life_break = class({})
function modifier_huskar_custom_life_break:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_DISABLE_HEALING,
    }
end
function modifier_huskar_custom_life_break:GetDisableHealing()
    return 1
end
if IsServer() then
    function modifier_huskar_custom_life_break:OnCreated()
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.radius = self.ability:GetSpecialValueFor("radius") 
		self.interval = self.ability:GetSpecialValueFor("interval") 
		self.multiplier = 1 + (self.ability:GetSpecialValueFor("multiplier") * 0.01)
		self.animCounter = 0
		self:SetStackCount(self.ability:GetSpecialValueFor("damage"))
		self:StartIntervalThink(self.interval)
		self.particle = ParticleManager:CreateParticle("particles/custom/huskar_custom_life_break_channel.vpcf", PATTACH_POINT, self.caster)
		ParticleManager:SetParticleControlEnt(self.particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	end
	function modifier_huskar_custom_life_break:OnIntervalThink() 
		self:SetStackCount(self:GetStackCount() * self.multiplier)
		self.animCounter = self.animCounter + 3
		ParticleManager:SetParticleControl(self.particle, 1, Vector(self.animCounter, 0, self.animCounter))
		
		local units = FindUnitsInRadius(self.parent:GetTeam(), 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			0, 
			false
		)
		local parentIndex = self.parent:entindex()
		for _, unit in ipairs(units) do
        ExecuteOrderFromTable({
            UnitIndex = unit:entindex(), 
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = parentIndex
        })
		end
	end
	function modifier_huskar_custom_life_break:OnDestroy() 
		local units = FindUnitsInRadius(self.parent:GetTeam(), 
			self.parent:GetAbsOrigin(), 
			nil, 
			self.radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, 
			0, 
			false
		)
		for _, unit in ipairs(units) do
			if unit then
				ApplyDamage({
				attacker = self.parent,
				victim = unit,
				ability = self.ability,
				damage_type = self.ability:GetAbilityDamageType(),
				damage = self:GetStackCount() / #units
			})
			end
		end
		ParticleManager:DestroyParticle(self.particle,  true)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire_ring_b.vpcf", PATTACH_POINT, self.caster)
		ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_ABSORIGIN, "attach_absorigin", self.parent:GetAbsOrigin(), true)
		local particle = ParticleManager:CreateParticle("particles/custom/huskar_custom_life_break_end.vpcf", PATTACH_POINT, self.caster)
		ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_ABSORIGIN, "attach_absorigin", self.parent:GetAbsOrigin(), true)
	end
end
LinkLuaModifier("modifier_huskar_talent1", "abilities/heroes/huskar_custom_life_break.lua", LUA_MODIFIER_MOTION_NONE)
modifier_huskar_talent1 = class({})

function modifier_huskar_talent1:IsHidden()
    return true
end


function modifier_huskar_talent1:IsPurgable()
    return false
end

function modifier_huskar_talent1:RemoveOnDeath()
	return false
end