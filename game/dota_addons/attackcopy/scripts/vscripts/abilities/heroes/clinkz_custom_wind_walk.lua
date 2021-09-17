
clinkz_custom_wind_walk = class({})


function clinkz_custom_wind_walk:OnSpellStart()
    local caster = self:GetCaster()
	self.modifier = caster:AddNewModifier(
		caster,
		self,
		"modifier_clinkz_custom_wind_walk_fade", -- modifier name
		{duration = self:GetSpecialValueFor("fade_time")} -- kv
	)
end

function clinkz_custom_wind_walk:OnUpgrade()
	local caster = self:GetCaster()
	if not caster:HasAbility("clinkz_custom_ward_buff") then
		local ability_ward_buff = caster:AddAbility("clinkz_custom_ward_buff")
		ability_ward_buff:SetLevel(1)
	end
end

function clinkz_custom_wind_walk:OnInventoryContentsChanged()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("frostivus2018_clinkz_burning_army")
	if caster:HasScepter() and ability then
		ability:SetLevel(1)
		ability:SetHidden(false)
	else
		ability:SetHidden(true)
	end
end

function RotateVector2D(v,theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end

LinkLuaModifier("modifier_generic_summon_timer", "lib/modifiers/modifier_generic_summon_timer.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_custom_wind_walk_fade", "abilities/heroes/clinkz_custom_wind_walk.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_wind_walk_fade = class({})
function modifier_clinkz_custom_wind_walk_fade:IsHidden()
	return true
end

function modifier_clinkz_custom_wind_walk_fade:OnCreated()
		local parent = self:GetParent()
		local particle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:ReleaseParticleIndex(particle)
	end
function modifier_clinkz_custom_wind_walk_fade:OnDestroy()
	local parent = self:GetParent()
	if IsServer() then
		local modifier = parent:AddNewModifier(
			parent,
			self:GetAbility(),
			"modifier_clinkz_custom_wind_walk",
			{duration = self:GetAbility():GetSpecialValueFor("duration")}
		)
	end
end


LinkLuaModifier("modifier_clinkz_custom_wind_walk", "abilities/heroes/clinkz_custom_wind_walk.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_wind_walk = class({})

function modifier_clinkz_custom_wind_walk:IsDebuff()
	return false
end

function modifier_clinkz_custom_wind_walk:IsHidden()
	return false
end

function modifier_clinkz_custom_wind_walk:IsPurgable()
	return false
end

-- Declare Functions
function modifier_clinkz_custom_wind_walk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_clinkz_custom_wind_walk:GetModifierInvisibilityLevel()
	return 1
end
function modifier_clinkz_custom_wind_walk:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("move_speed_bonus_pct")
end
function modifier_clinkz_custom_wind_walk:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
	}
	return state
end

if IsServer() then
	function modifier_clinkz_custom_wind_walk:OnCreated()
		self.parent = self:GetParent()
	end
	
	function modifier_clinkz_custom_wind_walk:OnDestroy()
		if self.parent:HasModifier("modifier_item_aghanims_shard") then
			local caster_origin = self.parent:GetOrigin()
			local caster_direction = self.parent:GetRightVector()
			local offset = Vector(100, 0 , 0)
			local p = self.parent:GetAbsOrigin()
			local fv = self.parent:GetForwardVector()
			local p2 = p - 150*RotateVector2D(fv, math.rad(90))
			local p3 = p + 150*RotateVector2D(fv, math.rad(90))
			local skeleton = CreateUnitByName("npc_dota_clinkz_skeleton_archer_frostivus2018", p2, true, self.parent, self.parent:GetOwner(),self.parent:GetTeamNumber())
			skeleton:SetControllableByPlayer(self.parent:GetPlayerID(), true)
			skeleton:SetOwner(self.parent)
			skeleton:SetForwardVector(fv)
			if self.parent:HasAbility("frostivus2018_clinkz_searing_arrows") then
				skeleton:RemoveAbility("frostivus2018_clinkz_searing_arrows")
				local searing = skeleton:AddAbility("frostivus2018_clinkz_searing_arrows")
				searing:UpgradeAbility(true)
				searing:SetLevel( self.parent:FindAbilityByName("frostivus2018_clinkz_searing_arrows"):GetLevel() )
				searing:ToggleAutoCast()
			end
			local caster_damage = (self.parent:GetBaseDamageMax() + self.parent:GetBaseDamageMin()) / 2
			skeleton:SetBaseAttackTime(1.0)
			skeleton:SetBaseDamageMin(caster_damage)
			skeleton:SetBaseDamageMax(caster_damage)
			skeleton:AddNewModifier(self.parent, self, "modifier_clinkz_custom_wind_walk_summon", {
			duration = 20})
			skeleton:AddNewModifier(self.parent, self, "modifier_generic_summon_timer", {
			duration = 20})
			
			local skeleton = CreateUnitByName("npc_dota_clinkz_skeleton_archer_frostivus2018", p3, true, self.parent, self.parent:GetOwner(),self.parent:GetTeamNumber())
			skeleton:SetControllableByPlayer(self.parent:GetPlayerID(), true)
			skeleton:SetOwner(self.parent)
			skeleton:SetForwardVector(fv)
			if self.parent:HasAbility("frostivus2018_clinkz_searing_arrows") then
				skeleton:RemoveAbility("frostivus2018_clinkz_searing_arrows")
				local searing = skeleton:AddAbility("frostivus2018_clinkz_searing_arrows")
				searing:UpgradeAbility(true)
				searing:SetLevel( self.parent:FindAbilityByName("frostivus2018_clinkz_searing_arrows"):GetLevel() )
				searing:ToggleAutoCast()
			end
			local caster_damage = (self.parent:GetBaseDamageMax() + self.parent:GetBaseDamageMin()) / 2
			skeleton:SetBaseAttackTime(1.0)
			skeleton:SetBaseDamageMin(caster_damage)
			skeleton:SetBaseDamageMax(caster_damage)
			skeleton:AddNewModifier(self.parent, self, "modifier_clinkz_custom_wind_walk_summon", {
			duration = 20})
			skeleton:AddNewModifier(self.parent, self, "modifier_generic_summon_timer", {
			duration = 20})
		end
	end

	function modifier_clinkz_custom_wind_walk:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self.parent then 
			self:Destroy()
		end
	end
end

LinkLuaModifier("modifier_clinkz_custom_wind_walk_summon", "abilities/heroes/clinkz_custom_wind_walk.lua", LUA_MODIFIER_MOTION_NONE)
modifier_clinkz_custom_wind_walk_summon = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_clinkz_custom_wind_walk_summon:IsDebuff()
	return true
end

function modifier_clinkz_custom_wind_walk_summon:IsHidden()
	return true
end

function modifier_clinkz_custom_wind_walk_summon:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_clinkz_custom_wind_walk_summon:OnDestroy()
	if IsServer() then
		self:GetParent():ForceKill( false )
	end
end

--------------------------------------------------------------------------------
-- Declare Functions
function modifier_clinkz_custom_wind_walk_summon:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
end


function modifier_clinkz_custom_wind_walk_summon:GetModifierTotal_ConstantBlock(keys)
	return keys.damage - 2
end



