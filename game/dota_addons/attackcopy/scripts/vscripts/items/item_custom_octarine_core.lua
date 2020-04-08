
item_custom_octarine_core = class({})

function item_custom_octarine_core:GetIntrinsicModifierName()
    return "modifier_item_custom_octarine_core"
end

item_custom_octarine_core_1 = class(item_custom_octarine_core)
item_custom_octarine_core_2 = class(item_custom_octarine_core)

LinkLuaModifier("modifier_item_custom_octarine_core", "items/item_custom_octarine_core.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_octarine_core = class({})


function modifier_item_custom_octarine_core:IsHidden()
    return true
end
function modifier_item_custom_octarine_core:IsPurgable()
	return false
end

function modifier_item_custom_octarine_core:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_custom_octarine_core:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end


function modifier_item_custom_octarine_core:GetModifierHealthBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_custom_octarine_core:GetModifierManaBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_custom_octarine_core:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intelligence")
end



if IsServer() then
	function modifier_item_custom_octarine_core:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.lifesteal = self.ability:GetSpecialValueFor("lifesteal") * 0.01
		Timers:CreateTimer(
			0.25, 
			function()
				self.parent:RemoveModifierByName("modifier_item_custom_octarine_core_reduction")
				self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_custom_octarine_core_reduction", {})
			end
		)
		
		self.particle_name = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	end
	
	function modifier_item_custom_octarine_core:OnDestroy()
		self.parent:RemoveModifierByName("modifier_item_custom_octarine_core_reduction")
	end
	
	function modifier_item_custom_octarine_core:OnTakeDamage(keys)
		if keys.attacker:HasModifier("modifier_item_custom_octarine_core") then
			if self.parent == keys.attacker and keys.unit ~= self.parent then
				if keys.damage_flags ~= 16 and keys.damage_type ~= 1 then
					self.parent:Heal(keys.original_damage * self.lifesteal, self)
					ParticleManager:CreateParticle(self.particle_name, PATTACH_ABSORIGIN_FOLLOW, self.parent)
				end
			end
		end
	end
	
end

LinkLuaModifier("modifier_item_custom_octarine_core_reduction", "items/item_custom_octarine_core.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_custom_octarine_core_reduction = class({})

function modifier_item_custom_octarine_core_reduction:IsHidden()
    return true
end

function modifier_item_custom_octarine_core_reduction:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
end
function modifier_item_custom_octarine_core_reduction:IsPurgable()
	return false
end
function modifier_item_custom_octarine_core_reduction:RemoveOnDeath()
	return false
end

function modifier_item_custom_octarine_core_reduction:GetModifierPercentageCooldown()
    return self:GetAbility():GetSpecialValueFor("bonus_cooldown")
end