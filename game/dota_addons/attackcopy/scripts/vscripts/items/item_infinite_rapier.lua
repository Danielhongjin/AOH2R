


item_infinite_rapier = class({})
function item_infinite_rapier:GetIntrinsicModifierName()
    return "modifier_item_infinite_rapier"
end
LinkLuaModifier("modifier_item_infinite_rapier_base", "items/item_infinite_rapier.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_infinite_rapier_base = class({})

function modifier_item_infinite_rapier_base:IsHidden()
    return true
end

function modifier_item_infinite_rapier_base:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end

function modifier_item_infinite_rapier_base:GetModifierBaseAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_base_damage")
end

LinkLuaModifier("modifier_item_infinite_rapier", "items/item_infinite_rapier.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_infinite_rapier = class({})

function modifier_item_infinite_rapier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_infinite_rapier:IsPurgable()
    return false
end

function modifier_item_infinite_rapier:GetTexture()
    return "infinite_rapier"
end

function modifier_item_infinite_rapier:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_infinite_rapier:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


function modifier_item_infinite_rapier:OnCreated()
	self.parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/custom/infinite_rapier_shell.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self.particle2 = ParticleManager:CreateParticle("particles/custom/infinite_rapier_smoke.vpcf", PATTACH_POINT, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	if IsServer() then
		if self.parent:IsHero() then
			self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_item_infinite_rapier_base", {})
		end
	end
end
function modifier_item_infinite_rapier:OnDestroy()
	ParticleManager:DestroyParticle(self.particle, true)
	ParticleManager:DestroyParticle(self.particle2,  true)
	if IsServer() then
		if self.parent:IsHero() then
			self.parent:RemoveModifierByName("modifier_item_infinite_rapier_base")
		end
	end
end
