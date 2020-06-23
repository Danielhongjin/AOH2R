LinkLuaModifier("modifier_bonus_secondary_controller", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_secondary_token", "modifiers/modifier_bonus.lua", LUA_MODIFIER_MOTION_NONE)


item_custom_rapier = class({})
function item_custom_rapier:GetIntrinsicModifierName()
    return "modifier_item_custom_rapier"
end

item_custom_rapier = class(item_custom_rapier)
item_ultimate_rapier = class(item_custom_rapier)
item_infinite_rapier = class(item_custom_rapier)

LinkLuaModifier("modifier_item_custom_rapier_base", "items/item_custom_rapier.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_rapier_base = class({})

function modifier_item_custom_rapier_base:IsHidden()
    return true
end
function modifier_item_custom_rapier_base:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_custom_rapier_base:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end


function modifier_item_custom_rapier_base:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_base_damage")
end

LinkLuaModifier("modifier_item_custom_rapier", "items/item_custom_rapier.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_rapier = class({})

function modifier_item_custom_rapier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_custom_rapier:IsPurgable()
    return false
end
function modifier_item_custom_rapier:IsHidden()
    return true
end
function modifier_item_custom_rapier:GetTexture()
    return "rapier"
end

function modifier_item_custom_rapier:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_custom_rapier:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


function modifier_item_custom_rapier:OnCreated()
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	if IsServer() then
		self.parent:AddNewModifier(self.parent, ability, "modifier_bonus_secondary_controller", {})
		self.statModifier = self.parent:AddNewModifier(self.parent, ability, "modifier_bonus_secondary_token", {
			bonus = ability:GetSpecialValueFor("secondary_stat_percent")})
		if self.parent:IsHero() then
			self.modifier = self.parent:AddNewModifier(self.parent, ability, "modifier_item_custom_rapier_base", {})
		end
		if ability:GetAbilityName() == "item_infinite_rapier" then
			self.modifierEffect = self.parent:AddNewModifier(self.parent, ability, "modifier_item_infinite_rapier_effect", {})
		end
	end
end

function modifier_item_custom_rapier:OnDestroy()
	if IsServer() then
		self.statModifier:Destroy()
		if self.parent:IsHero() then
			self.modifier:Destroy()
		end
		if self:GetAbility():GetAbilityName() == "item_infinite_rapier" then
			self.modifierEffect:Destroy()
		end
	end
end
LinkLuaModifier("modifier_item_infinite_rapier_effect", "items/item_custom_rapier.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_infinite_rapier_effect = class({})

function modifier_item_infinite_rapier_effect:OnCreated()
	self.parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/custom/infinite_rapier_shell.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self.particle2 = ParticleManager:CreateParticle("particles/custom/infinite_rapier_smoke.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
end
function modifier_item_infinite_rapier_effect:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, true)
	ParticleManager:DestroyParticle(self.particle2,  true)
end
function modifier_item_infinite_rapier_effect:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end