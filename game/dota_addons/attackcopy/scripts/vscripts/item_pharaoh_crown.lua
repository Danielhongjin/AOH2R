function aura_initiate(keys)
	local caster = keys.caster
	local parent = keys.target
	if caster ~= parent and not caster:GetUnitLabel() ~= "temp_unit" and not caster:IsIllusion()  then
		if caster:GetPlayerOwner() == parent:GetPlayerOwner() and not parent:HasModifier("modifier_pharaoh_crown_buff") and parent:GetUnitLabel() ~= "ancient" then
			if not parent:IsHero() and parent:GetMaxHealth() > 35 or parent:GetUnitLabel() == "pharaoh_ok" or parent:GetUnitLabel() == "temp_unit" then
				if parent:GetUnitName() ~= "npc_playerhelp" then
					parent:AddNewModifier(caster, keys.ability, "modifier_pharaoh_crown_buff", {})
				end
			end
		end
	end
end
LinkLuaModifier("modifier_pharaoh_crown_buff", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_buff = class({})
function modifier_pharaoh_crown_buff:GetTexture()
    return "pharaoh_crown"
end
function modifier_pharaoh_crown_buff:IsPurgable()
	return false
end
if IsServer() then
function modifier_pharaoh_crown_buff:OnDestroy(keys)
	self.parent:ForceKill(false)
end
function modifier_pharaoh_crown_buff:OnCreated()
	local ability = self:GetAbility()
	self.caster = ability:GetCaster()
	self.parent = self:GetParent()
	self.health = ability:GetSpecialValueFor("aura_health_mult")
	self.armor = ability:GetSpecialValueFor("aura_armor") * 0.01
	self.damage = ability:GetSpecialValueFor("aura_damage_mult")
	self.magic_resistance = ability:GetSpecialValueFor("aura_magic_resistance")
	self.interval = ability:GetSpecialValueFor("interval")
	self.parent_health = self.parent:GetMaxHealth()
	self.parent_damage = (self.parent:GetBaseDamageMax() + self.parent:GetBaseDamageMin()) / 2
	self.parent_regen = self.parent:GetBaseHealthRegen()
	self.parent_armor = self.parent:GetPhysicalArmorBaseValue()
	self.parent_magical_armor = self.parent:GetBaseMagicalResistanceValue()
	self.caster_base_damage = (self.caster:GetBaseDamageMax() + self.caster:GetBaseDamageMin()) / 2
	if self.parent:IsConsideredHero() then
		self.parentishero = true
	else
		self.parentishero = false
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
		self.healthmodifier = self.parent:AddNewModifier(self.parent, ability, "modifier_pharaoh_crown_health", {})
		self.healthmodifier:SetStackCount(self.parent_health * (self.caster:GetMaxHealth() / self.health))
	end
	self.armormodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_armor", {})
	self.armormodifier:SetStackCount(self.caster:GetPhysicalArmorValue(false) * self.armor)
	self.damagemodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_damage", {})
	self.damagemodifier:SetStackCount((self.parent_damage * ((self.caster:GetAverageTrueAttackDamage(self.caster) - self.caster_base_damage) / 2 + self.caster_base_damage)) / self.damage)
	self.regenmodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_regen", {})
	self.regenmodifier:SetStackCount(self.parent_regen * (self.caster:GetMaxHealth() / self.health))
	self.magicarmormodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_magic_armor", {})
	self.magicarmormodifier:SetStackCount(self.magic_resistance)
	self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_super_armor", {duration = 3.0})
	self:StartIntervalThink(self.interval)
end
function modifier_pharaoh_crown_buff:OnIntervalThink()
	if self.parent:IsNull() or self.caster:IsNull() then
		self:Destroy()
		return
	end
	if self.parentishero then
		self.tempHealth = self.parent:GetHealth() / self.parent:GetMaxHealth() * 1.00000
		self.parent:SetMaxHealth(self.parent_health + (self.parent_health * (self.caster:GetMaxHealth() / self.health)))
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
		self.healthmodifier = self.parent:AddNewModifier(self.parent, ability, "modifier_pharaoh_crown_health", {})
		self.healthmodifier:SetStackCount(self.parent_health * (self.caster:GetMaxHealth() / self.health))
		self.healthmodifier:ForceRefresh()
	end
	self.armormodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_armor", {})
	self.armormodifier:SetStackCount(self.caster:GetPhysicalArmorValue(false) * self.armor)
	self.damagemodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_damage", {})
	self.damagemodifier:SetStackCount((self.parent_damage * ((self.caster:GetAverageTrueAttackDamage(self.caster) - self.caster_base_damage) / 2 + self.caster_base_damage)) / self.damage)
	self.regenmodifier = self.parent:AddNewModifier(self.caster, ability, "modifier_pharaoh_crown_regen", {})
	self.regenmodifier:SetStackCount(self.parent_regen * (self.caster:GetMaxHealth() / self.health))
	if self.parent:GetHealth() < 1 then
		self.parent:ForceKill(true)
	end
end
end
LinkLuaModifier("modifier_pharaoh_crown_health", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_health = class({})
function modifier_pharaoh_crown_health:IsBuff()
    return true
end
function modifier_pharaoh_crown_health:IsHidden()
    return true
end
function modifier_pharaoh_crown_health:IsPurgable()
    return false
end
function modifier_pharaoh_crown_health:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }
end
function modifier_pharaoh_crown_health:GetModifierExtraHealthBonus()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_pharaoh_crown_damage", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_damage = class({})
function modifier_pharaoh_crown_damage:IsBuff()
    return true
end
function modifier_pharaoh_crown_damage:IsHidden()
    return true
end
function modifier_pharaoh_crown_damage:IsPurgable()
    return false
end
function modifier_pharaoh_crown_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end
function modifier_pharaoh_crown_damage:GetModifierBaseAttack_BonusDamage()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_pharaoh_crown_armor", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_armor = class({})
function modifier_pharaoh_crown_armor:IsBuff()
    return true
end
function modifier_pharaoh_crown_armor:IsHidden()
    return true
end
function modifier_pharaoh_crown_armor:IsPurgable()
    return false
end
function modifier_pharaoh_crown_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
end
function modifier_pharaoh_crown_armor:GetModifierPhysicalArmorBonus()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_pharaoh_crown_regen", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_regen = class({})
function modifier_pharaoh_crown_regen:IsBuff()
    return true
end
function modifier_pharaoh_crown_regen:IsHidden()
    return true
end
function modifier_pharaoh_crown_regen:IsPurgable()
    return false
end
function modifier_pharaoh_crown_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
    }
end
function modifier_pharaoh_crown_regen:GetModifierConstantHealthRegen()
    return self:GetStackCount()
end
function modifier_pharaoh_crown_regen:GetModifierHealthRegenPercentage()
    return 1.5
end
LinkLuaModifier("modifier_pharaoh_crown_magic_armor", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_magic_armor = class({})
function modifier_pharaoh_crown_magic_armor:IsBuff()
    return true
end
function modifier_pharaoh_crown_magic_armor:IsHidden()
    return true
end
function modifier_pharaoh_crown_magic_armor:IsPurgable()
    return false
end
function modifier_pharaoh_crown_magic_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
end
function modifier_pharaoh_crown_magic_armor:GetModifierMagicalResistanceBonus()
    return self:GetStackCount()
end
LinkLuaModifier("modifier_pharaoh_crown_super_armor", "items/item_pharaoh_crown.lua", LUA_MODIFIER_MOTION_NONE)
modifier_pharaoh_crown_super_armor = class({})
function modifier_pharaoh_crown_super_armor:IsBuff()
    return true
end
function modifier_pharaoh_crown_super_armor:IsHidden() 
	return true
end
function modifier_pharaoh_crown_super_armor:IsPurgable()
    return false
end
function modifier_pharaoh_crown_super_armor:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
end
function modifier_pharaoh_crown_super_armor:GetModifierIncomingDamage_Percentage()
    return -50;
end