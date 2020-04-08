require("lib/my")


custom_techies_behavior = class({})


function custom_techies_behavior:GetIntrinsicModifierName()
	if not self:GetCaster():IsIllusion() then
		return "modifier_custom_techies_behavior"
	end
end




LinkLuaModifier("modifier_custom_techies_behavior", "bosses/custom_techies_behavior.lua", LUA_MODIFIER_MOTION_NONE)

modifier_custom_techies_behavior = class({})


function modifier_custom_techies_behavior:IsHidden()
    return true
end
function modifier_custom_techies_behavior:IsPurgable()
	return false
end



if IsServer() then
	function modifier_custom_techies_behavior:OnCreated()
		self.parent = self:GetParent()
		self.team = self.parent:GetTeam()
		self.ability = self:GetAbility()
		self.mineAbility = self.parent:FindAbilityByName("custom_land_mines")
		self.interval = self.ability:GetSpecialValueFor("interval")
		self.randomRadius  = self.ability:GetSpecialValueFor("radius")
		local hero = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, 2400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for k, unit in pairs(hero) do
			local location = unit:GetAbsOrigin() + (self.randomRadius + RandomInt(0, 400))*RotateVector2D(unit:GetForwardVector(), math.rad(RandomInt(0, 360)))
			self.parent:CastAbilityOnPosition(location, self.mineAbility, -1)

			break
		end
		local randomTime = RandomInt(0, 99) * 0.01
		Timers:CreateTimer({
			endTime = randomTime, 
			callback = function()
			  self:StartIntervalThink(self.interval)
			end
		})
		
	end
	function modifier_custom_techies_behavior:OnIntervalThink()
		local hero = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for k, unit in pairs(hero) do
			local location = unit:GetAbsOrigin() + (self.randomRadius + RandomInt(-100, 100))*RotateVector2D(unit:GetForwardVector(), math.rad(RandomInt(0, 360)))
			self.parent:CastAbilityOnPosition(location, self.mineAbility, -1)

			break
		end
	end
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

