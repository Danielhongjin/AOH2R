require("lib/my")

item_plain_ring = class({})

function item_plain_ring:GetIntrinsicModifierName()
    return "modifier_item_plain_ring_aura"
end

LinkLuaModifier("modifier_item_plain_ring_aura", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_aura = class({})


if IsServer() then
    function modifier_item_plain_ring_aura:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
			if not parent:IsIllusion() and parent:GetUnitLabel() ~= "spirit_bear" then
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_plain_ring", {})
				EmitSoundOn("Hero_Antimage.Counterspell.Absorb", parent)
			end
        end
    end
end


function modifier_item_plain_ring_aura:IsHidden()
    return true
end

function modifier_item_plain_ring_aura:IsPurgable()
	return false
end
function modifier_item_plain_ring_aura:IsAura()
    return true
end


function modifier_item_plain_ring_aura:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius")
end


function modifier_item_plain_ring_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end


function modifier_item_plain_ring_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_item_plain_ring_aura:GetModifierAura()
    return "modifier_item_plain_ring_buff"
end


function modifier_item_plain_ring_aura:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_plain_ring_aura:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_item_plain_ring_aura:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end



LinkLuaModifier("modifier_item_plain_ring_buff", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_buff = class({})

function modifier_item_plain_ring_buff:GetTexture()
	return "plain_ring"
end
function modifier_item_plain_ring_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
end


function modifier_item_plain_ring_buff:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("aura_armor")
end


function modifier_item_plain_ring_buff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("aura_mana_regen")
end

LinkLuaModifier("modifier_item_plain_ring", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring = class({})

function modifier_item_plain_ring:IsHidden()
	return true
end
function modifier_item_plain_ring:IsPurgable()
	return false
end

if IsServer() then



function modifier_item_plain_ring:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end


function modifier_item_plain_ring:OnCreated(keys)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.invincibility_duration = self.ability:GetSpecialValueFor("duration")
	self.cooldown = self.ability:GetCooldown(0)
end


function modifier_item_plain_ring:OnTakeDamage(keys)
	local attacker = keys.attacker
	local unit = keys.unit
	if self.parent == unit and self.ability:IsCooldownReady() and self.parent:GetHealth() < 1  then
		if has_item(self.parent, "item_plain_ring") then

			self.parent:SetHealth(1)
			self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_plain_ring_invincibility", {duration = self.invincibility_duration})
			self.ability:StartCooldown(self.cooldown * self.parent:GetCooldownReduction())
		else
			self:Destroy()
		end
	end
end




end
LinkLuaModifier("modifier_item_plain_ring_invincibility", "items/item_plain_ring.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_plain_ring_invincibility = class({})
if IsServer() then
function modifier_item_plain_ring_invincibility:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
end

function modifier_item_plain_ring_invincibility:IsPurgable()
	return false
end
function modifier_item_plain_ring_invincibility:GetMinHealth()
	return 1
end

function modifier_item_plain_ring_invincibility:OnDestroy()
local parent = self:GetParent()
	ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	parent:Heal((parent:GetMaxHealth() * self:GetAbility():GetSpecialValueFor("min_health") * 0.01), self:GetAbility())
end
end
function modifier_item_plain_ring_invincibility:GetTexture()
	return "plain_ring_invincibility"
end
function modifier_item_plain_ring_invincibility:GetEffectName()
	return "particles/world_shrine/dire_shrine_regen.vpcf"
end

function modifier_item_plain_ring_invincibility:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end