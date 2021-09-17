
item_demon_talon = class({})

function item_demon_talon:GetIntrinsicModifierName()
    return "modifier_item_demon_talon"
end
function item_demon_talon:OnSpellStart()
    local caster = self:GetCaster()
	if self:GetAbilityName() == "item_greater_demon_talon" then
		local item = find_item(caster, "item_greater_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_magi_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	elseif self:GetAbilityName() == "item_magi_demon_talon" then
		local item = find_item(caster, "item_magi_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_greater_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	end
end

function item_demon_talon:OnUpgrade()
    local caster = self:GetCaster()
	if self:GetAbilityName() == "item_greater_demon_talon" then
		local item = find_item(caster, "item_greater_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_magi_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	elseif self:GetAbilityName() == "item_magi_demon_talon" then
		local item = find_item(caster, "item_magi_demon_talon")
		local purchase_time = item:GetPurchaseTime()
		caster:RemoveItem(item)
		local item2 = caster:AddItemByName("item_greater_demon_talon")
		item2:SetPurchaseTime(purchase_time)
	end
end
item_greater_demon_talon = class(item_demon_talon)
item_magi_demon_talon = class(item_demon_talon)

LinkLuaModifier("modifier_item_demon_talon", "items/item_demon_talon.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_demon_talon = class({})


function modifier_item_demon_talon:IsHidden()
    return true
end
function modifier_item_demon_talon:IsPurgable()
	return false
end

function modifier_item_demon_talon:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_demon_talon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end


function modifier_item_demon_talon:GetModifierConstantHealthRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function modifier_item_demon_talon:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_demon_talon:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

if IsServer() then
	function modifier_item_demon_talon:OnCreated()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.damage = self.ability:GetSpecialValueFor("proc_damage")
		if not self.parent:IsIllusion() and not self.parent:IsInvulnerable() and not self.parent:IsTempestDouble() then
			if self.ability:GetAbilityName() == "item_magi_demon_talon" then
				_G.AOHGameMode.SetTalon(self.parent:GetOwner():GetPlayerID(), 0, self.damage)
			else 
				_G.AOHGameMode.SetTalon(self.parent:GetOwner():GetPlayerID(), self.damage, 0)
			end
		end
	end
	function modifier_item_demon_talon:OnDestroy()
		if not self.parent:IsIllusion() and not self.parent:IsInvulnerable() and not self.parent:IsTempestDouble() then
			if self.ability:GetAbilityName() == "item_magi_demon_talon" then
				_G.AOHGameMode.SetTalon(self.parent:GetOwner():GetPlayerID(), 0, -self.damage)
			else 
				_G.AOHGameMode.SetTalon(self.parent:GetOwner():GetPlayerID(), -self.damage, 0)
			end
		end
	end
end