require("lib/my")
require("lib/popup")

antimage_custom_speed = class({})


function antimage_custom_speed:GetIntrinsicModifierName()
    return "modifier_antimage_custom_speed"
end




LinkLuaModifier("modifier_antimage_custom_speed", "abilities/heroes/antimage_custom_speed.lua", LUA_MODIFIER_MOTION_NONE)

modifier_antimage_custom_speed = class({})


function modifier_antimage_custom_speed:IsHidden()
    return true
end


if IsServer() then
    function modifier_antimage_custom_speed:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
        }
    end
    function modifier_antimage_custom_speed:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.duration = self.ability:GetSpecialValueFor("duration")
		self.damage_type = self.ability:GetAbilityDamageType()
		self.damage = self.ability:GetSpecialValueFor("damage")
		self.manaCost = self.ability:GetManaCost(1)
    end
    
    function modifier_antimage_custom_speed:OnAttackStart(keys)
        local attacker = keys.attacker
        if attacker ~= self.parent then 
            return 
        end
		if self.ability:GetCooldownTimeRemaining() > 0 or attacker:GetMana() < self.manaCost then
			return
		end
        local target = keys.target
		if target ~= null then
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_antimage_custom_speed_active", {duration = self.duration})
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_rune_haste", {duration = self.duration})
			self.ability:UseResources(true, false, true)
			self.parent:EmitSoundParams("Hero_AntiMage.ManaVoid", 0, 0.6, 0)
			local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControlEnt(fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(fx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(400, 0, 0), true)
			ParticleManager:ReleaseParticleIndex(fx)
			ApplyDamage({
				ability = self.ability,
				attacker = self.parent,
				damage = self.damage,
				damage_type = self.damage_type,
				victim = target
			})
		end

    end
end

LinkLuaModifier("modifier_antimage_custom_speed_active", "abilities/heroes/antimage_custom_speed.lua", LUA_MODIFIER_MOTION_NONE)

modifier_antimage_custom_speed_active = class({})


function modifier_antimage_custom_speed_active:IsHidden()
    return false
end

function modifier_antimage_custom_speed_active:GetTexture()
    return "antimage_mana_void"
end

function modifier_antimage_custom_speed_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
end
	
function modifier_antimage_custom_speed_active:GetModifierBaseAttackTimeConstant()
    return self:GetAbility():GetSpecialValueFor("base_attack_time")
end

	