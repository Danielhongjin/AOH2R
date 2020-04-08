function scepter(keys)
    local ability = keys.ability
    local caster = keys.caster
	if caster:HasScepter() then
		local caster_origin = caster:GetOrigin()
		local caster_direction = caster:GetRightVector()
		local offset = Vector(100, 0 , 0)
		local p = caster:GetAbsOrigin()
		local fv = caster:GetForwardVector()
		local p3 = p + 150*RotateVector2D(fv, math.rad(90))
		local p2 = p - 150*RotateVector2D(fv, math.rad(90))
		local skeleton = CreateUnitByName("npc_dota_clinkz_skeleton_archer_frostivus2018", p3, true, caster, caster:GetOwner(),caster:GetTeamNumber())
		local skeleton2 = CreateUnitByName("npc_dota_clinkz_skeleton_archer_frostivus2018", p2, true, caster, caster:GetOwner(),caster:GetTeamNumber())
		skeleton:SetControllableByPlayer(caster:GetPlayerID(), true)
		skeleton2:SetControllableByPlayer(caster:GetPlayerID(), true)
		skeleton:SetOwner(caster)
		skeleton2:SetOwner(caster)

		if caster:HasAbility("frostivus2018_clinkz_searing_arrows") then
			skeleton:RemoveAbility("frostivus2018_clinkz_searing_arrows")
			local searing = skeleton:AddAbility("frostivus2018_clinkz_searing_arrows")
			searing:UpgradeAbility(true)
			searing:SetLevel( caster:FindAbilityByName("frostivus2018_clinkz_searing_arrows"):GetLevel() )
			searing:ToggleAutoCast()
			skeleton2:RemoveAbility("frostivus2018_clinkz_searing_arrows")
			local searing2 = skeleton2:AddAbility("frostivus2018_clinkz_searing_arrows")
			searing2:UpgradeAbility(true)
			searing2:SetLevel( caster:FindAbilityByName("frostivus2018_clinkz_searing_arrows"):GetLevel() )
			searing2:ToggleAutoCast()
		end
		local caster_damage = (caster:GetBaseDamageMax() + caster:GetBaseDamageMin()) / 2
		skeleton:SetBaseAttackTime(1.0)
		skeleton:SetBaseDamageMin(caster_damage)
		skeleton:SetBaseDamageMax(caster_damage)
		skeleton2:SetBaseAttackTime(1.0)
		skeleton2:SetBaseDamageMin(caster_damage)
		skeleton2:SetBaseDamageMax(caster_damage)
		skeleton:AddNewModifier(caster, self, "modifier_clinkz_custom_wind_walk", {
        duration = 20})
		skeleton2:AddNewModifier(caster, self, "modifier_clinkz_custom_wind_walk", {
        duration = 20})
		skeleton:AddNewModifier(caster, self, "modifier_generic_summon_timer", {
        duration = 20})
		skeleton2:AddNewModifier(caster, self, "modifier_generic_summon_timer", {
        duration = 20})
	end
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end
LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_custom_wind_walk", "abilities/heroes/clinkz_custom_wind_walk.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_wind_walk = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_clinkz_custom_wind_walk:IsDebuff()
	return true
end

function modifier_clinkz_custom_wind_walk:IsHidden()
	return true
end

function modifier_clinkz_custom_wind_walk:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_clinkz_custom_wind_walk:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill( false )
	end
end

--------------------------------------------------------------------------------
-- Declare Functions
function modifier_clinkz_custom_wind_walk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end


function modifier_clinkz_custom_wind_walk:GetModifierTotal_ConstantBlock(keys)
	return keys.damage - 2
end



