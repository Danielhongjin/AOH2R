LinkLuaModifier("modifier_skill_midas", "modifiers/modifier_tier_5.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_license", "modifiers/modifier_tier_5.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_license_cooldown", "modifiers/modifier_tier_5.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_luck", "modifiers/modifier_tier_5.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skill_wavedash", "modifiers/modifier_tier_5.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_attackspeed_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_strength_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_agility_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_intellect_controller", "modifiers/stat_controllers.lua", LUA_MODIFIER_MOTION_NONE)
require("lib/my")
modifier_skill_midas = class({})

function modifier_skill_midas:IsPurgable()
    return false
end

function modifier_skill_midas:IsDebuff()
    return false
end

function modifier_skill_midas:RemoveOnDeath()
    return false
end

function modifier_skill_midas:AllowIllusionDuplicate()
    return false
end

function modifier_skill_midas:GetTexture()
    return "modifier_skill_midas"
end

function modifier_skill_midas:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

if IsServer() then
	function modifier_skill_midas:OnCreated()
		self.parent = self:GetParent()
		self.parent_id = self.parent:GetPlayerOwnerID()
		self.round = 0
		self.value = 1
		self:StartIntervalThink(5)
	end
	function modifier_skill_midas:OnIntervalThink()
		local round = _G.AOHGameMode._nRoundNumber
		if round and round > self.round then
			local rand = RandomInt(0, 2)
			if rand == 0 then
				_G.AOHGameSkills.AddCurrency(self.parent_id, self.value)
			end
			self.round = round
			
		end
	end
	function modifier_skill_midas:OnAttackLanded(keys)
		local attacker = keys.attacker
		local target = keys.target
		if attacker == self:GetParent() and not target:IsNull() then 
			local finaldamage = ApplyDamage({
				ability = nil,
				attacker = attacker,
				damage = 20 * _G.AOHGameSkills.currency[self.parent_id],
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 16,
				victim = target,
			})
			create_popup({
				target = target,
				value = finaldamage,
				color = Vector(200, 195, 47),
				type = "spell",
				pos = 6
			})
		end
	end
end

modifier_skill_license = class({})

function modifier_skill_license:IsPurgable()
    return false
end

function modifier_skill_license:IsDebuff()
    return false
end

function modifier_skill_license:RemoveOnDeath()
    return false
end

function modifier_skill_license:AllowIllusionDuplicate()
    return true
end

function modifier_skill_license:GetTexture()
    return "modifier_skill_license"
end

function modifier_skill_license:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end



if IsServer() then
	function modifier_skill_license:OnCreated()
		self.parent = self:GetParent()
		self.cooldown = 0
		self.interval = 0.5
	end
	function modifier_skill_license:OnIntervalThink()
		self.cooldown = self.cooldown - self.interval
		if self.cooldown <= 0 then
			self.cooldown = 0
			self:StartIntervalThink(-1)
		end
	end
	function modifier_skill_license:OnAbilityFullyCast(keys)
		local unit = keys.unit
		if unit == self.parent and self.cooldown == 0 then
			local used_ability = keys.ability
			if used_ability and not ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_CHANNELLED) then
				local cursor = used_ability:GetCursorPosition()
				Timers:CreateTimer(
					0.7,
					function()
						if used_ability and self.parent:IsAlive() then  -- test again, object may have been deleted.
							if ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and keys.target then
								self.parent:SetCursorCastTarget(keys.target)
							elseif ability_behavior_includes(used_ability, DOTA_ABILITY_BEHAVIOR_POINT) then
								self.parent:SetCursorPosition(cursor)
							else
								self.parent:SetCursorTargetingNothing(true)
							end
							used_ability:OnSpellStart()
						end
						self.cooldown = 5 * self.parent:GetCooldownReduction()
						self.parent:AddNewModifier(self.parent, nil, "modifier_skill_license_cooldown", {duration = self.cooldown})
						self:StartIntervalThink(self.interval)
					end
				)
			end
		end
	end
end

modifier_skill_license_cooldown = class({})

function modifier_skill_license_cooldown:IsPurgable()
    return false
end

function modifier_skill_license_cooldown:IsDebuff()
    return false
end

function modifier_skill_license_cooldown:GetTexture()
    return "modifier_skill_license"
end

modifier_skill_luck = class({})

function modifier_skill_luck:IsPurgable()
    return false
end

function modifier_skill_luck:IsDebuff()
    return false
end

function modifier_skill_luck:RemoveOnDeath()
    return false
end

function modifier_skill_luck:AllowIllusionDuplicate()
    return false
end

function modifier_skill_luck:GetTexture()
    return "modifier_skill_luck"
end

function modifier_skill_luck:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
	}
	return funcs
end
if IsServer() then
	function modifier_skill_luck:GetModifierPreAttack_CriticalStrike(keys)
		if RandomInt(0, 100) < 6 then
			return RandomInt(150, 2000)
		end
	end
	
	function modifier_skill_luck:GetModifierTotal_ConstantBlock(keys)
		if RandomInt(0, 100) < 6 then
			return 99999
		end
	end
	
	function modifier_skill_luck:OnCreated()
		self.parent = self:GetParent()
		self.round = 0
		self.strength_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_strength_controller", {})
		self.agility_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_agility_controller", {})
		self.intellect_modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_intellect_controller", {})
		self:StartIntervalThink(5)
	end
	function modifier_skill_luck:OnIntervalThink()
		local round = _G.AOHGameMode._nRoundNumber
		if round and round > self.round then
			local rand = RandomInt(0, 2)
			local fx = ParticleManager:CreateParticle("particles/custom/modifier_luck.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
			ParticleManager:SetParticleControl(fx, 1, Vector(4, 0, 4))
			EmitSoundOn("sounds/weapons/hero/ogre_magi/multicast01.vsnd", self.parent)
			if rand == 0 then
				self.strength_modifier:ModifyStacks(2)
				local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			elseif rand == 1 then
				self.agility_modifier:ModifyStacks(2)
				local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti8/hero_levelup_ti8_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			else
				self.intellect_modifier:ModifyStacks(2)
				local fx2 = ParticleManager:CreateParticle("particles/econ/events/ti7/hero_levelup_ti7_flash_hit_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(fx2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			end
			self.round = round
		end
	end
	
end
modifier_skill_wavedash = class({})

function modifier_skill_wavedash:IsPurgable()
    return false
end

function modifier_skill_wavedash:IsDebuff()
    return false
end

function modifier_skill_wavedash:RemoveOnDeath()
    return false
end

function modifier_skill_wavedash:AllowIllusionDuplicate()
    return true
end

function modifier_skill_wavedash:GetTexture()
    return "modifier_skill_wavedash"
end

function modifier_skill_wavedash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
	}
	return funcs
end

function modifier_skill_wavedash:GetModifierAttackPointConstant()
	return 0.2
end


if IsServer() then
	function modifier_skill_wavedash:OnCreated()
		self.parent = self:GetParent()
		self.modifier = self.parent:AddNewModifier(self.parent, nil, "modifier_bonus_attackspeed_token", {bonus = -35})
	end
	function modifier_skill_wavedash:OnDestroy()
		self.modifier:Destroy()
	end
end



