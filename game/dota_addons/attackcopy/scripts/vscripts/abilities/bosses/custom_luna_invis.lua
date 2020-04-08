require("lib/my")


custom_luna_invis = class({})


function custom_luna_invis:OnSpellStart()
	local caster = self:GetCaster()
	caster:Purge(false, true, false, true, false)
	caster:AddNewModifier(
		caster,
		self,
		"modifier_custom_luna_invis", -- modifier name
		{ duration = self:GetSpecialValueFor("duration") } -- kv
	)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_ray.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_ABSORIGIN, "attach_absorigin", caster:GetAbsOrigin(), true)
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_cast.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	ParticleManager:ReleaseParticleIndex(particle2)
end

LinkLuaModifier("modifier_custom_luna_invis_behavior", "abilities/bosses/custom_luna_invis.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_luna_invis_behavior = class({})


function modifier_custom_luna_invis_behavior:IsHidden()
    return true
end
function modifier_custom_luna_invis_behavior:IsPurgable()
	return false
end
function modifier_custom_luna_invis_behavior:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    }
end

function modifier_custom_luna_invis_behavior:GetModifierMoveSpeedBonus_Percentage()
    return 250
end

function modifier_custom_luna_invis_behavior:GetModifierTurnRate_Percentage()
    return 100
end

function modifier_custom_luna_invis_behavior:GetModifierPercentageCasttime()
    return 50
end

function modifier_custom_luna_invis_behavior:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end
LinkLuaModifier("modifier_custom_luna_invis", "abilities/bosses/custom_luna_invis.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_luna_invis = class({})


function modifier_custom_luna_invis:IsHidden()
    return true
end
function modifier_custom_luna_invis:IsPurgable()
	return false
end
function modifier_custom_luna_invis:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end
function modifier_custom_luna_invis:GetModifierAttackSpeedBonus_Constant()
    return 250
end

if IsServer() then
	function modifier_custom_luna_invis:OnCreated()
		self.parent = self:GetParent()
		self.team = self.parent:GetTeam()
		self.ability = self:GetAbility()
		self.mineAbility = self.parent:FindAbilityByName("luna_lucent_beam")
		self.parent:FindAbilityByName("custom_eclipse"):StartCooldown(20)
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.aggro_duration = self.ability:GetSpecialValueFor("aggro_duration")
		self.randomRadius  = self.ability:GetSpecialValueFor("radius")
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
		ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", self.parent:GetAbsOrigin(), true)
		self:OnIntervalThink()
		self:StartIntervalThink(self.interval)
	end
	function modifier_custom_luna_invis:OnIntervalThink()
		local hero = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		self.modifier = self.parent:AddNewModifier(self.parent,self.ability,"modifier_custom_luna_invis_behavior",{duration = 1.5})
		self.parent:AddNewModifier(self.parent,self.ability,"modifier_invisible",{duration = 2})
		for k, unit in pairs(hero) do
			local location = unit:GetAbsOrigin() + (self.randomRadius)*RotateVector2D(unit:GetForwardVector(), math.rad(RandomInt(0, 360)))
			self.parent:MoveToPosition(location)
			Timers:CreateTimer({
				endTime = self.aggro_duration, 
				callback = function()
					self.mineAbility:EndCooldown()
					if unit then
						self.parent:CastAbilityOnTarget(unit, self.mineAbility, -1)
						ExecuteOrderFromTable({
							UnitIndex = self.parent:entindex(), 
							OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
							TargetIndex = unit:entindex()
						})
					end
				end
			})
			break
		end
	end
	function modifier_custom_luna_invis:OnDestroy()
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
		self.modifier:Destroy()
		
	end
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

