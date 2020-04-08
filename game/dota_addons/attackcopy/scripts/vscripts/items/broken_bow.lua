

item_broken_bow = class({})


function item_broken_bow:GetIntrinsicModifierName()
    return "modifier_item_broken_bow"
end



LinkLuaModifier("modifier_item_broken_bow", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow = class({})


if IsServer() then
    function modifier_item_broken_bow:OnCreated(keys)
        local parent = self:GetParent()

        if parent then
            parent:AddNewModifier(parent, self:GetAbility(), "modifier_item_broken_bow_thinker", {})
        end
    end
	function modifier_item_broken_bow:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName("modifier_item_broken_bow_thinker")
		parent:RemoveModifierByName("modifier_item_broken_bow_count")
	end
end


function modifier_item_broken_bow:IsHidden()
    return true
end
function modifier_item_broken_bow:IsPurgable()
	return false
end

function modifier_item_broken_bow:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_broken_bow:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    }
end


function modifier_item_broken_bow:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end


function modifier_item_broken_bow:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_int")
end


function modifier_item_broken_bow:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end


function modifier_item_broken_bow:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("movement_speed_bonus")
end

function modifier_item_broken_bow:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_broken_bow:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_broken_bow:GetModifierAttackRangeBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_range")
end


LinkLuaModifier("modifier_item_broken_bow_thinker", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_thinker = class({})


function modifier_item_broken_bow_thinker:IsHidden()
    return true
end
function modifier_item_broken_bow_thinker:IsPurgable()
	return false
end

function modifier_item_broken_bow_thinker:RemoveOnDeath()
    return false
end


if IsServer() then
    function modifier_item_broken_bow_thinker:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        }
    end
	
	function modifier_item_broken_bow_thinker:OnCreated()
		self.parent = self:GetParent()
		self.attacks_needed = self:GetAbility():GetSpecialValueFor("attacks_needed")
		self.stack_count = 0
		self.count_modifier = self.parent:AddNewModifier(self.parent, self, "modifier_item_broken_bow_count", {})
	end


    function modifier_item_broken_bow_thinker:OnAttackLanded(keys)
        local attacker = keys.attacker
        if attacker == self.parent and not attacker:IsNull() then
			self.stack_count = self.stack_count + 1
            if self.stack_count > self.attacks_needed - 1 then
				self.stack_count = -1
				self.count_modifier:SetStackCount(self.stack_count)
				attacker:PerformAttack(keys.target, true, true, true, true, true, false, false) 
            else 
				self.count_modifier:SetStackCount(self.stack_count)
            end
			
        end
    end
end



LinkLuaModifier("modifier_item_broken_bow_count", "items/broken_bow.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_broken_bow_count = class({})

function modifier_item_broken_bow_count:IsPurgable()
	return false
end
function modifier_item_broken_bow_count:GetTexture()
    return "item_ForaMon/broken_bow"
end
function modifier_item_broken_bow_count:RemoveOnDeath()
    return false
end
