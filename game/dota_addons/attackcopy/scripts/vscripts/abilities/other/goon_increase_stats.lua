require("lib/my")
require("AOHGameMode")





function on_created(keys)
	local caster = keys.caster
	local ability = keys.ability

	local round = 0
	local armor_base = caster:GetPhysicalArmorBaseValue()
	local magical_armor_base = caster:GetMagicalResistanceValue()
	local armor_per_round = ability:GetSpecialValueFor("armor_per_round")
	local previous_round = 1
	caster:AddItemByName("item_force_blade")
	caster:AddItemByName("item_heart")
	caster:AddItemByName("item_boss_resistance_25")
	caster:SetHasInventory(false)
	caster:SetCanSellItems(false)
	caster:AddNewModifier(caster, ability, "modifier_goon_invincibility", {})
	caster:AddNewModifier(caster, nil, "modifier_builtin_blink", {duration = -1})
	local has5 = false
	local has10 = false
	local has15 = false
	local has20 = false
	local has25 = false
	local has30 = false
	local has35 = false
	Timers:CreateTimer(
		function()
			round = GameRules.GLOBAL_roundNumber
			if round ~= previous_round and round then
				if caster and not caster:IsNull() and caster:IsAlive() and caster:FindAbilityByName("goon_increase_stats") then
					local level = caster:GetLevel()
					caster:CreatureLevelUp(round - level)
					if round > 5 and not has5 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_lesser_crit")
						caster:SetHasInventory(false)
						has5 = true
					end
					if round > 10 and not has10 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_holy_locket")
						caster:SetHasInventory(false)
						has10 = true
					end
					if round > 15 and not has15 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_heart"))
						caster:AddItemByName("item_great_heart")
						caster:SetHasInventory(false)
						has15 = true
					end
					if round > 20 and not has20 then
						caster:SetHasInventory(true)
						caster:AddItemByName("item_satanic")
						caster:SetHasInventory(false)
						has20 = true
					end
					if round > 25 and not has25 then
						caster:SetHasInventory(true)
						caster:AddNewModifier(caster, ability, "modifier_goon_increase_stats", {})
						caster:RemoveItem(find_item(caster, "item_great_heart"))
						caster:AddItemByName("item_ultimate_heart")
						caster:AddItemByName("item_ultimate_scepter")
						caster:SetHasInventory(false)
						has25 = true
					end
					if round > 30 and not has30 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_lesser_crit"))
						caster:AddItemByName("item_greater_crit")
						caster:SetHasInventory(false)
						has30 = true
					end
					if round > 35 and not has35 then
						caster:SetHasInventory(true)
						caster:RemoveItem(find_item(caster, "item_greater_crit"))
						caster:AddItemByName("item_ultimate_crit")
						caster:SetHasInventory(false)
						has35 = true
					end
					previous_round = round
				end
			end
		return 2.0
	end
	)
end	

LinkLuaModifier("modifier_builtin_blink", "abilities/other/hero_attribute_fix.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_goon_increase_stats", "abilities/other/goon_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)
modifier_goon_increase_stats = class({})

function modifier_goon_increase_stats:GetTexture()
    return "dragon_knight_dragon_blood"
end

function modifier_goon_increase_stats:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    }
end

function modifier_goon_increase_stats:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_goon_increase_stats:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("bonus_spell_amp")
end

function modifier_goon_increase_stats:OnCreated()
	self.parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end
function modifier_goon_increase_stats:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, true)
end


LinkLuaModifier("modifier_goon_invincibility", "abilities/other/goon_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)
modifier_goon_invincibility = class({})
function modifier_goon_invincibility:IsHidden()
	return true
end
function modifier_goon_invincibility:IsPurgable()
	return false
end
function modifier_goon_invincibility:RemoveOnDeath()
	return false
end

function modifier_goon_invincibility:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_goon_invincibility:OnCreated()
	self.parent = self:GetParent()
end
function modifier_goon_invincibility:OnTakeDamage(keys)
	local attacker = keys.attacker
	local unit = keys.unit
	if self.parent == unit and self.parent:GetHealth() < 1 then
		if not self.parent:HasModifier("modifier_goon_injured") then
			self.parent:SetHealth(1)
			self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_goon_revive", {duration = self:GetAbility():GetSpecialValueFor("reincarnate_time")})
		end
	end
end

LinkLuaModifier("modifier_goon_revive", "abilities/other/goon_increase_stats.lua", LUA_MODIFIER_MOTION_NONE)
modifier_goon_revive = class({})

function modifier_goon_revive:GetTexture()
    return "dragon_knight_dragon_tail"
end

function modifier_goon_revive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}
end
function modifier_goon_revive:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
function modifier_goon_revive:IsPurgable()
	return false
end
function modifier_goon_revive:GetMinHealth()
	return 1
end
function modifier_goon_revive:GetModifierHealthRegenPercentage()
	return 6
end

function modifier_goon_revive:GetTexture()
	return "plain_ring_invincibility"
end

function modifier_goon_revive:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function modifier_goon_revive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end