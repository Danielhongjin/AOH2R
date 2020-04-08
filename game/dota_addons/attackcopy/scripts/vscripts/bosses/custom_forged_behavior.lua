require("lib/my")


custom_forged_behavior = class({})


function custom_forged_behavior:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_custom_forged_behavior"
	end
end




LinkLuaModifier("modifier_custom_forged_behavior", "bosses/custom_forged_behavior.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_forged_behavior = class({})


function modifier_custom_forged_behavior:IsHidden()
    return true
end
function modifier_custom_forged_behavior:IsPurgable()
	return false
end



if IsServer() then
	function modifier_custom_forged_behavior:OnCreated()
		self.parent = self:GetParent()
		self.team = self.parent:GetTeam()
		self.ability = self:GetAbility()
		self.mineAbility = self.parent:FindAbilityByName("custom_mortimer_kisses")
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.radius  = self.ability:GetSpecialValueFor("radius")
		
		local randomTime = RandomInt(0, 99) * 0.01
		Timers:CreateTimer({
			endTime = randomTime, 
			callback = function()
			local hero = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
			for k, unit in pairs(hero) do
				self.parent:CastAbilityOnPosition(unit:GetAbsOrigin(), self.mineAbility, -1)
				break
			end
			  self:StartIntervalThink(self.interval)
			end
		})
		
	end
	function modifier_custom_forged_behavior:OnIntervalThink()
		local hero = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for k, unit in pairs(hero) do
			self.parent:CastAbilityOnPosition(unit:GetAbsOrigin(), self.mineAbility, -1)

			break
		end
	end
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

