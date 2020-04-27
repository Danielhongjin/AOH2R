
LinkLuaModifier("modifier_item_sanguine", "items/item_sanguine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sanguine_token", "items/item_sanguine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sanguine_controller", "items/item_sanguine.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_sanguine_buff", "items/item_sanguine.lua", LUA_MODIFIER_MOTION_NONE)



item_sanguine = class({})

function item_sanguine:GetIntrinsicModifierName()
    return "modifier_item_sanguine"
end



modifier_item_sanguine_token = class({})

function modifier_item_sanguine_token:IsHidden()
    return true
end
function modifier_item_sanguine_token:IsPurgable()
	return false
end

function modifier_item_sanguine_token:RemoveOnDeath()
	return false
end

function modifier_item_sanguine_token:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

if IsServer() then
	function modifier_item_sanguine_token:OnCreated(keys)
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_item_sanguine_controller")
		self.bonus = keys.bonus
		self.modifier:SetStackCount(self.modifier:GetStackCount() + self.bonus)
		self.modifier:ForceRefresh()
	end
	function modifier_item_sanguine_token:OnDestroy()
		self.modifier:SetStackCount(self.modifier:GetStackCount() - self.bonus)
		self.modifier:ForceRefresh()
	end
end

modifier_item_sanguine_controller = class({})

function modifier_item_sanguine_controller:IsHidden()
    return true
end

function modifier_item_sanguine_controller:IsPurgable()
	return false
end

function modifier_item_sanguine_controller:RemoveOnDeath()
	return false
end


if IsServer() then
	function modifier_item_sanguine_controller:OnCreated()
		self.parent = self:GetParent()
		self.modifier = self.parent:FindModifierByName("modifier_item_sanguine_buff")
		self.multiplier = 1
		self:StartIntervalThink(0.33)
	end

	function modifier_item_sanguine_controller:OnRefresh()
		local temp = (self:GetStackCount() / 9) - 1
		if temp > 0 then
			self.multiplier = math.pow(0.75, temp)
		else
			self.multiplier = 1
		end
	end
	
	function modifier_item_sanguine_controller:OnIntervalThink()
		if self:GetStackCount() <= 0 then
			self.modifier:Destroy()
			self:Destroy()
		end
		self.modifier:SetStackCount(self.parent:GetMaxHealth() * self:GetStackCount() * self.multiplier * 0.01) 
	end
end

modifier_item_sanguine_buff = class({})

function modifier_item_sanguine_buff:IsHidden()
    return true
end
function modifier_item_sanguine_buff:IsPurgable()
	return false
end

function modifier_item_sanguine_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_item_sanguine_buff:RemoveOnDeath()
	return false
end
if IsServer() then
	function modifier_item_sanguine_buff:OnCreated(keys)
		self.parent = self:GetParent()
		self.damage_ratio = keys.ratio
	end
	function modifier_item_sanguine_buff:OnAttackLanded(keys)
        local attacker = keys.attacker
        local target = keys.target
		if not self.parent:IsIllusion() then
			if attacker == self.parent and attacker ~= target then
				ApplyDamage({
					ability = ability,
					attacker = attacker,
					damage = self:GetStackCount() * self.damage_ratio,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
					victim = attacker,
				})
				local particle = ParticleManager:CreateParticle("particles/econ/items/lifestealer/ls_ti9_immortal/ls_ti9_open_wounds_blood_soft.vpcf", PATTACH_POINT_FOLLOW, attacker)
				ParticleManager:SetParticleControlEnt(particle, 0, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true) 
				ParticleManager:ReleaseParticleIndex(particle)
			end
		end
    end
end
function modifier_item_sanguine_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

modifier_item_sanguine = class({})


function modifier_item_sanguine:IsHidden()
    return true
end
function modifier_item_sanguine:IsPurgable()
	return false
end
function modifier_item_sanguine:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_sanguine:DeclareFunctions()
    return {
        
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
end

function modifier_item_sanguine:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_sanguine:GetModifierMagicalResistanceBonus()
        return self:GetAbility():GetSpecialValueFor("bonus_magical_resistance")
end

function modifier_item_sanguine:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


if IsServer() then
	function modifier_item_sanguine:OnCreated()
		self.parent = self:GetParent()
		if not self.parent:IsIllusion() then
			local ability = self:GetAbility()
			self.parent:AddNewModifier(self.parent, ability, "modifier_item_sanguine_buff", {ratio = ability:GetSpecialValueFor("damage_ratio") * 0.01})
			self.parent:AddNewModifier(self.parent, ability, "modifier_item_sanguine_controller", {})
			self.modifier = self.parent:AddNewModifier(self.parent, ability, "modifier_item_sanguine_token", {
				bonus = self:GetAbility():GetSpecialValueFor("health_damage_bonus")})
		end
	end
		
	function modifier_item_sanguine:OnDestroy()
		if not self.parent:IsIllusion() then
			self.modifier:Destroy()
		end
	end
end
