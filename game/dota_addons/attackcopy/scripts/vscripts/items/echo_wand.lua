--[[Author: Nightborn
	Date: August 27, 2016
]]
require("lib/my")
require("lib/popup")


item_echo_wand = class({})


function item_echo_wand:GetIntrinsicModifierName()
    return "modifier_item_echo_wand"
end

function item_echo_wand:OnSpellStart()
    local caster = self:GetCaster()
	if not caster:HasModifier("modifier_item_echo_wand_block") then
		if not caster:HasModifier("modifier_item_echo_wand_lock") then
			caster:AddNewModifier(caster, self, "modifier_item_echo_wand_lock", {})
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_defensive.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(fx)
			EmitSoundOn("Hero_Antimage.ManaVoidCast", caster)
		else
			caster:RemoveModifierByName("modifier_item_echo_wand_lock")
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_defensive_splash.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(fx)
		end
	else
		print("Caughtcha")
	end
end
LinkLuaModifier("modifier_item_echo_wand_lock", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand_lock = class({})

function modifier_item_echo_wand_lock:IsHidden()
    return false
end

function modifier_item_echo_wand_lock:IsPurgable()
	return false
end

function modifier_item_echo_wand_lock:RemoveOnDeath()
    return false
end

function modifier_item_echo_wand_lock:GetTexture()
    return "echo_wand_disabled"
end

LinkLuaModifier("modifier_item_echo_wand", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand = class({})


if IsServer() then
    function modifier_item_echo_wand:OnCreated(keys)
        local parent = self:GetParent()

        if parent and parent:IsRealHero() then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_echo_wand_thinker", {})
        end
    end
	function modifier_item_echo_wand:OnDestroy()
        local parent = self:GetParent()
		parent:RemoveModifierByName("modifier_item_echo_wand_thinker")
    end
end


function modifier_item_echo_wand:IsHidden()
    return true
end

function modifier_item_echo_wand:IsPurgable()
	return false
end


function modifier_item_echo_wand:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_item_echo_wand:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_echo_wand:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_echo_wand:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
LinkLuaModifier("modifier_item_echo_wand_thinker", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_echo_wand_thinker = class({})


function modifier_item_echo_wand_thinker:IsHidden()
    return true
end

function modifier_item_echo_wand_thinker:IsPurgable()
	return false
end
function modifier_item_echo_wand_thinker:RemoveOnDeath()
    return false
end

if IsServer() then
    function modifier_item_echo_wand_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        }
    end
	
	local exclude_table = {
		item_arcane_boots = true,
		item_custom_refresher = true,
		item_custom_ex_machina = true,
		item_guardian_greaves = true,
		item_conduit = true,
		item_custom_fusion_rune = true,
		item_black_king_bar = true,
		item_pocket_tower = true,
		item_pocket_barracks = true,
		item_echo_wand = true,
		phoenix_fire_spirits = true,
		phantom_assassin_custom_stifling_dagger = true,
		ursa_enrage = true,
		weaver_time_lapse = true,
		faceless_void_time_walk = true,
		riki_smoke_screen = true,
		viper_nethertoxin = true,
	}
	local include_table = {
		riki_blink_strike = true,
		phantom_assassin_phantom_strike = true,
	}
	function modifier_item_echo_wand_thinker:OnCreated()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.echo = nil
		self.targetType = nil
		self.cooldown_reduction = self.ability:GetSpecialValueFor("cooldown_reduction")
		self.minimum_cooldown = self.ability:GetSpecialValueFor("minimum_cooldown")
		self.cooldown_threshold = self.ability:GetSpecialValueFor("cooldown_threshold")
	end
	
	function modifier_item_echo_wand_thinker:OnAbilityExecuted(keys)
		if keys.unit == self.parent and not self.parent:HasModifier("modifier_item_echo_wand_lock") and (keys.ability:GetCooldown(keys.ability:GetLevel()) * self.parent:GetCooldownReduction()) <= self.cooldown_threshold and not keys.ability:IsToggle() then
			if not exclude_table[keys.ability:GetAbilityName()] then
				if (ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and (keys.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_ENEMY or keys.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_BOTH)) or include_table[keys.ability:GetAbilityName()] then
					self.targetType = 0
					self.echo = keys.ability
				elseif ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_POINT) then
					self.targetType = 1
					self.echo = keys.ability
				elseif ability_behavior_includes(keys.ability, DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
					self.targetType = 2
					self.echo = keys.ability
				end
			end
		end
	end

	function modifier_item_echo_wand_thinker:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self.parent and not keys.target:IsNull() then 
			if self.echo and self.ability:IsCooldownReady() then
				if self.echo:IsOwnersManaEnough() then
					if self.targetType == 0 then
						self.parent:SetCursorCastTarget(keys.target)
					elseif self.targetType == 1 then
						self.parent:SetCursorPosition(keys.target:GetAbsOrigin())
					else
						self.parent:SetCursorTargetingNothing(true)
					end
					self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_echo_wand_block", {duration = 1})
					local cooldown = self.echo:GetCooldown(self.echo:GetLevel()) * self.parent:GetCooldownReduction()
					if cooldown < self.minimum_cooldown then
						cooldown = self.minimum_cooldown
					end
					local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_rubick/rubick_nullfield_offensive.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
					ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(fx)
					self.parent:CastAbilityImmediately(self.ability, -1)
					self.ability:StartCooldown(cooldown)
					Timers:CreateTimer(
						0.05,
						function()
							self.ability:StartCooldown(cooldown)
							self.echo:OnSpellStart()
							self.echo:SetChanneling(true)
							self.echo:EndChannel(true)
							self.echo:UseResources(true, false, false)
						end
					)
				end
			elseif keys.target:IsConsideredHero() and self.ability:GetCooldownTimeRemaining() > self.minimum_cooldown then
				local cooldown = self.ability:GetCooldownTimeRemaining() - (keys.damage / keys.target:GetMaxHealth() * self.cooldown_reduction * 100)
				if cooldown < self.minimum_cooldown then
					cooldown = self.minimum_cooldown
				end
				self.ability:EndCooldown()
				self.ability:StartCooldown(cooldown)
			end
		end
	end
end

LinkLuaModifier("modifier_item_echo_wand_block", "items/echo_wand.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_echo_wand_block = class({})

function modifier_item_echo_wand_block:IsHidden()
    return true
end

function modifier_item_echo_wand_block:IsPurgable()
	return false
end

