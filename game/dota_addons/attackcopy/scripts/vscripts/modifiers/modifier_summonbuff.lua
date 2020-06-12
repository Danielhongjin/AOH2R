
modifier_summonbuff = class({})


function modifier_summonbuff:GetTexture()
    return "summonbuff"
end

function modifier_summonbuff:IsPurgable()
	return false
end

function modifier_summonbuff:GetTexture()
    return "pharaoh_crown"
end

 
if IsServer() then

function modifier_summonbuff:OnDestroy(keys)
	self.parent:ForceKill(false)
end


function modifier_summonbuff:OnCreated(keys)
	self.caster = PlayerResource:GetSelectedHeroEntity(keys.id)
	self.parent = self:GetParent()
	self.health = 2000
	self.armor = 0.33
	self.damage = 95
	self.parent_health = self.parent:GetMaxHealth()
	self.parent_damage = (self.parent:GetBaseDamageMax() + self.parent:GetBaseDamageMin()) / 2
	self.parent_regen = self.parent:GetBaseHealthRegen()
	self.parent_armor = self.parent:GetPhysicalArmorBaseValue()
	self.caster_base_damage = (self.caster:GetBaseDamageMax() + self.caster:GetBaseDamageMin()) / 2
	self.parentishero = false
	if self.parent:IsConsideredHero() then
		self.parentishero = true
	end
	if self.parent:GetUnitLabel() == "pharaoh_ok" then
		self.health = 400000
	end
	if self.parent:GetUnitLabel() == "temp_unit" then
		self.health = 10000000
	end
	if self.parentishero then
		self.tempHealth = self.parent:GetHealthPercent()
		self.parent:SetMaxHealth(self.parent_health + (self.parent_health * (self.caster:GetMaxHealth() / self.health)))
		self.parent:SetHealth(self.parent:GetMaxHealth() * self.tempHealth * 0.01)
	else
		self.healthmodifier = self.parent:AddNewModifier(self.parent, ability, "modifier_summonbuff_health", {})
		self.healthmodifier:SetStackCount(self.parent_health * (self.caster:GetMaxHealth() / self.health))
	end
	self.armormodifier = self.parent:AddNewModifier(self.caster, self.ability, "modifier_summonbuff_armor", {})
	self.armormodifier:SetStackCount(self.caster:GetPhysicalArmorValue(false) * self.armor)
	self.damagemodifier = self.parent:AddNewModifier(self.caster, self.ability, "modifier_summonbuff_damage", {})
	self.damagemodifier:SetStackCount((self.parent_damage * ((self.caster:GetAverageTrueAttackDamage(self.caster) - self.caster_base_damage) / 2.5 + self.caster_base_damage)) / self.damage)
	self.regenmodifier = self.parent:AddNewModifier(self.caster, self.ability, "modifier_summonbuff_regen", {})
	self.regenmodifier:SetStackCount(self.parent_regen * (self.caster:GetMaxHealth() / self.health))
	self.magicarmormodifier = self.parent:AddNewModifier(self.caster, self.ability, "modifier_summonbuff_magic_armor", {})
	self.parent:AddNewModifier(self.caster, self.ability, "modifier_summonbuff_super_armor", {duration = 3.0})
	self:StartIntervalThink(0.66)
end
function modifier_summonbuff:OnIntervalThink()
	if self.parent:IsNull() or self.caster:IsNull() then
		self:Destroy()
		return
	end
	local caster_max_health = self.caster:GetMaxHealth()
	if self.parentishero then
		self.tempHealth = self.parent:GetHealth() / self.parent:GetMaxHealth() * 1.00000
		self.parent:SetMaxHealth(self.parent_health + (self.parent_health * (caster_max_health / self.health)))
		self.tempHealth = self.parent:GetMaxHealth() * self.tempHealth
		if self.tempHealth > 0 then
			self.parent:SetHealth(self.tempHealth)
		else
			self.parent:ApplyDamage({
				ability = ability,
				attacker = self.parent,
				damage = 9999,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
				victim = self.parent,
			})
		end
	else
		self.healthmodifier = self.parent:AddNewModifier(self.parent, ability, "modifier_summonbuff_health", {})
		self.healthmodifier:SetStackCount(self.parent_health * (caster_max_health / self.health))
	end
	self.armormodifier:SetStackCount(self.caster:GetPhysicalArmorValue(false) * self.armor)
	self.damagemodifier:SetStackCount((self.parent_damage * ((self.caster:GetAverageTrueAttackDamage(self.caster) - self.caster_base_damage) / 2.5 + self.caster_base_damage)) / self.damage)
	self.regenmodifier:SetStackCount(self.parent_regen * (caster_max_health / self.health))
	if self.parent:GetHealth() < 1 then
		self.parent:ForceKill(true)
	end
end
end
LinkLuaModifier("modifier_summonbuff_health", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_health = class({})
function modifier_summonbuff_health:IsBuff()
    return true
end
function modifier_summonbuff_health:IsHidden()
    return true
end
function modifier_summonbuff_health:IsPurgable()
    return false
end
function modifier_summonbuff_health:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }
end
function modifier_summonbuff_health:GetModifierExtraHealthBonus()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_summonbuff_damage", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_damage = class({})
function modifier_summonbuff_damage:IsBuff()
    return true
end
function modifier_summonbuff_damage:IsHidden()
    return true
end
function modifier_summonbuff_damage:IsPurgable()
    return false
end
function modifier_summonbuff_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end
function modifier_summonbuff_damage:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_summonbuff_armor", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_armor = class({})
function modifier_summonbuff_armor:IsBuff()
    return true
end
function modifier_summonbuff_armor:IsHidden()
    return true
end
function modifier_summonbuff_armor:IsPurgable()
    return false
end
function modifier_summonbuff_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_summonbuff_armor:GetModifierPhysicalArmorBonus()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_summonbuff_regen", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_regen = class({})
function modifier_summonbuff_regen:IsBuff()
    return true
end
function modifier_summonbuff_regen:IsHidden()
    return true
end
function modifier_summonbuff_regen:IsPurgable()
    return false
end
function modifier_summonbuff_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end
function modifier_summonbuff_regen:GetModifierConstantHealthRegen()
    return self:GetStackCount()
end
function modifier_summonbuff_regen:GetModifierHealthRegenPercentage()
    return 1.5
end
LinkLuaModifier("modifier_summonbuff_magic_armor", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_magic_armor = class({})
function modifier_summonbuff_magic_armor:IsBuff()
    return true
end
function modifier_summonbuff_magic_armor:IsHidden()
    return true
end
function modifier_summonbuff_magic_armor:IsPurgable()
    return false
end
function modifier_summonbuff_magic_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_summonbuff_magic_armor:GetModifierMagicalResistanceBonus()
    return 25
end
LinkLuaModifier("modifier_summonbuff_super_armor", "modifiers/modifier_summonbuff.lua", LUA_MODIFIER_MOTION_NONE)
modifier_summonbuff_super_armor = class({})
function modifier_summonbuff_super_armor:IsBuff()
    return true
end
function modifier_summonbuff_super_armor:IsHidden() 
	return true
end
function modifier_summonbuff_super_armor:IsPurgable()
    return false
end
function modifier_summonbuff_super_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end
function modifier_summonbuff_super_armor:GetModifierIncomingDamage_Percentage()
    return -75;
end